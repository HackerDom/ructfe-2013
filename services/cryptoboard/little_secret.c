#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/proc_fs.h>
#include <linux/proc_fs.h>
#include <linux/ip.h>
#include <linux/in.h>
#include <linux/udp.h>
#include <linux/unistd.h>
#include <linux/if_ether.h>

#include <net/ip.h>
#include <linux/netfilter_ipv4.h>

#define WINDOW_SIZE 128
static unsigned int packets_count = 0;

static unsigned long a = 1664525;
static unsigned long c = 1013904223;
static unsigned int x;

#define MAX_PROC_READ_SIZE 4096
static unsigned char rnd_buf[MAX_PROC_READ_SIZE];

static ssize_t read_proc(struct file *filp, char *buf, size_t count, loff_t *offp) {
    if (count > MAX_PROC_READ_SIZE)
        count = MAX_PROC_READ_SIZE;

    printk("proc read. count = %zu, x = %#010x\n", count, x);
    for (size_t i = 0; i < count; i += 4) {
        rnd_buf[i]   = (x >> 8*0) & 0xFF;
        rnd_buf[i+1] = (x >> 8*1) & 0xFF;
        rnd_buf[i+2] = (x >> 8*2) & 0xFF;
        rnd_buf[i+3] = (x >> 8*3) & 0xFF;
        x = a * x + c;
    }

    copy_to_user(buf, rnd_buf, count);
    return count;
}

static struct file_operations proc_fops = {
    read:   read_proc
};

static int proc_init (void) {
    proc_create("random", 0, NULL, &proc_fops);
    return 0;
}

static void proc_cleanup(void) {
    remove_proc_entry("random", NULL);
}


static unsigned int hook_func_in(unsigned int hooknum, struct sk_buff *skb, const struct net_device *in, const struct net_device *out, int (*okfn)(struct sk_buff *)) {
    // check *in is the correct device
    // if (in is not the correct device)
    //     return NF_ACCEPT;         

    struct ethhdr *eth_header = eth_hdr(skb);

    u_int16_t etype = ntohs(eth_header->h_proto);
    if(etype != ETH_P_IP)
        return NF_ACCEPT;

    struct iphdr *ip_header = ip_hdr(skb);    
    if(ip_header == NULL)
        return NF_ACCEPT;

    if(ip_header->protocol != IPPROTO_UDP)
        return NF_ACCEPT;

    // printk("src mac %pM, dst mac %pM\n", eth_header->h_source, eth_header->h_dest);
    // printk("src IP addr = %pI4\n", &ip_header->saddr);

    struct udphdr *udp_header = udp_hdr(skb);
    if(udp_header == NULL)
        return NF_ACCEPT;

    uint data_len = ntohs(udp_header->len) - 8;
    if (data_len <= 0)
        return NF_ACCEPT;

    // printk("dst UDP PORT = %hu\n", udp_header->dest);   

    if (packets_count++ % WINDOW_SIZE != 0)
        return NF_ACCEPT;

    unsigned int *udp_data = (unsigned int*)udp_header;
    unsigned int xor = 0;
    for (int i = 0; i <= (data_len + 8)/ 4; i++)
        xor ^= udp_data[i];
    x = xor;

    printk("Recalculating RNG params, packets count = %u, a = %lu, c = %lu\n", packets_count - 1, a, c);   

    return NF_ACCEPT;
}

static struct nf_hook_ops nfin;

static void subscribe_on_packets(void) {
    nfin.hook     = hook_func_in;
    nfin.hooknum  = 1;//NF_IP_LOCAL_IN
    nfin.pf       = PF_INET;
    nfin.priority = NF_IP_PRI_FIRST;
    nf_register_hook(&nfin);
}

static void unsubscribe_from_packets(void) {
    nf_unregister_hook(&nfin);
}

static int __init init_main(void) {
    x = (unsigned long)(&x);
    subscribe_on_packets();
    proc_init();
    return 0;
}
static void __exit cleanup_main(void) {
    proc_cleanup();
    unsubscribe_from_packets();
}

module_init(init_main);
module_exit(cleanup_main);

MODULE_LICENSE("BSD");
MODULE_AUTHOR("kost");
MODULE_DESCRIPTION("RuCTFE 2013 random gen");


