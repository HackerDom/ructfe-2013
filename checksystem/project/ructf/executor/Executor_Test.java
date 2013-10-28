package ructf.executor;

import org.junit.*;
import static org.junit.Assert.*; 

public class Executor_Test
{
	@Test
	public void ExitCode() throws Exception
	{
		Executor ex = new Executor("perl tests/exec-test.pl", 500);
		ex.Execute("");
		assertFalse(ex.WasKilled());
		
		assertEquals(31337, ex.GetExitCode());
	}
	
	@Test
	public void Outputs() throws Exception
	{
		Executor ex = new Executor("perl tests/exec-test.pl", 500);
		ex.Execute("");
		assertFalse(ex.WasKilled());
		
		assertEquals("This\r\nis\r\nstdout", ex.GetStdout());
		assertEquals("This\r\nis\r\nstderr", ex.GetStderr());
	}
	
	@Test
	public void Arguments() throws Exception
	{
		Executor ex = new Executor("perl tests/print-arg.pl", 500);
		ex.Execute("FooBar");
		assertFalse(ex.WasKilled());
		
		assertEquals("The argument is: FooBar", ex.GetStdout());
	}
	
	@Test
	public void Timeout() throws Exception
	{
		Executor ex = new Executor("perl tests/sleep.pl", 500);
		ex.Execute("1");
		assertTrue(ex.WasKilled());
		
		assertEquals("Some..", ex.GetStdout());
	}
}
