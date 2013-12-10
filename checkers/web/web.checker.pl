#!/usr/bin/perl -lw
use 5.10.0;
use Mojo::UserAgent;
use Mojo::URL;
use Mojo::Upload;

my @names = (
    "Jacob", "Mason", "William", "Jayden", "Noah", "Michael", "Ethan",
    "Alexander", "Aiden", "Daniel", "Anthony", "Matthew", "Elijah",
    "Joshua", "Liam", "Andrew", "James", "David", "Benjamin",
    "Logan", "Christopher", "Joseph", "Jackson", "Gabriel", "Ryan",
    "Samuel", "John", "Nathan", "Lucas", "Christian", "Jonathan",
    "Caleb", "Dylan", "Landon", "Isaac", "Gavin", "Brayden",
    "Tyler", "Luke", "Evan", "Carter", "Nicholas", "Isaiah",
    "Owen", "Jack", "Jordan", "Brandon", "Wyatt", "Julian",
    "Aaron", "Jeremiah", "Angel", "Cameron", "Connor", "Hunter",
    "Adrian", "Henry", "Eli", "Justin", "Austin", "Robert",
    "Charles", "Thomas", "Zachary", "Jose", "Levi", "Kevin",
    "Sebastian", "Chase", "Ayden", "Jason", "Ian", "Blake",
    "Colton", "Bentley", "Dominic", "Xavier", "Oliver", "Parker",
    "Josiah", "Adam", "Cooper", "Brody", "Nathaniel", "Carson",
    "Jaxon", "Tristan", "Luis", "Juan", "Hayden", "Carlos",
    "Jesus", "Nolan", "Cole", "Alex", "Max", "Grayson",
    "Bryson", "Diego", "Jaden", "Vincent", "Easton", "Eric",
    "Micah", "Kayden", "Jace", "Aidan", "Ryder", "Ashton",
    "Bryan", "Riley", "Hudson", "Asher", "Bryce", "Miles",
    "Kaleb", "Giovanni", "Antonio", "Kaden", "Colin", "Kyle",
    "Brian", "Timothy", "Steven", "Sean", "Miguel", "Richard",
    "Ivan", "Jake", "Alejandro", "Santiago", "Axel", "Joel",
    "Maxwell", "Brady", "Caden", "Preston", "Damian", "Elias",
    "Jaxson", "Jesse", "Victor", "Patrick", "Jonah", "Marcus",
    "Rylan", "Emmanuel", "Edward", "Leonardo", "Cayden", "Grant",
    "Jeremy", "Braxton", "Gage", "Jude", "Wesley", "Devin",
    "Roman", "Mark", "Camden", "Kaiden", "Oscar", "Alan",
    "Malachi", "George", "Peyton", "Leo", "Nicolas", "Maddox",
    "Kenneth", "Mateo", "Sawyer", "Collin", "Conner", "Cody",
    "Andres", "Declan", "Lincoln", "Bradley", "Trevor", "Derek",
    "Tanner", "Silas", "Eduardo", "Seth", "Jaiden", "Paul",
    "Jorge", "Cristian", "Garrett", "Travis", "Abraham", "Omar",
    "Javier", "Ezekiel", "Tucker", "Harrison", "Peter", "Damien",
    "Greyson", "Avery", "Kai", "Weston", "Ezra", "Xander",
    "Jaylen", "Corbin", "Fernando", "Calvin", "Jameson", "Francisco",
    "Maximus", "Josue", "Ricardo", "Shane", "Trenton", "Cesar",
    "Chance", "Drake", "Zane", "Israel", "Emmett", "Jayce",
    "Mario", "Landen", "Kingston", "Spencer", "Griffin", "Stephen",
    "Manuel", "Theodore", "Erick", "Braylon", "Raymond", "Edwin",
    "Charlie", "Abel", "Myles", "Bennett", "Johnathan", "Andre",
    "Alexis", "Edgar", "Troy", "Zion", "Jeffrey", "Hector",
    "Shawn", "Lukas", "Amir", "Tyson", "Keegan", "Kyler",
    "Donovan", "Graham", "Simon", "Everett", "Clayton", "Braden",
    "Luca", "Emanuel", "Martin", "Brendan", "Cash", "Zander",
    "Jared", "Ryker", "Dante", "Dominick", "Lane", "Kameron",
    "Elliot", "Paxton", "Rafael", "Andy", "Dalton", "Erik",
    "Sergio", "Gregory", "Marco", "Emiliano", "Jasper", "Johnny",
    "Dean", "Drew", "Caiden", "Skyler", "Judah", "Maximiliano",
    "Aden", "Fabian", "Zayden", "Brennan", "Anderson", "Roberto",
    "Reid", "Quinn", "Angelo", "Holden", "Cruz", "Derrick",
    "Grady", "Emilio", "Finn", "Elliott", "Pedro", "Amari",
    "Frank", "Rowan", "Lorenzo", "Felix", "Corey", "Dakota",
    "Colby", "Braylen", "Dawson", "Brycen", "Allen", "Jax",
    "Brantley", "Ty", "Malik", "Ruben", "Trey", "Brock",
    "Colt", "Dallas", "Joaquin", "Leland", "Beckett", "Jett",
    "Louis", "Gunner", "Adan", "Jakob", "Cohen", "Taylor",
    "Arthur", "Marcos", "Marshall", "Ronald", "Julius", "Armando",
    "Kellen", "Dillon", "Brooks", "Cade", "Danny", "Nehemiah",
    "Beau", "Jayson", "Devon", "Tristen", "Enrique", "Randy",
    "Gerardo", "Pablo", "Desmond", "Raul", "Romeo", "Milo",
    "Julio", "Kellan", "Karson", "Titus", "Keaton", "Keith",
    "Reed", "Ali", "Braydon", "Dustin", "Scott", "Trent",
    "Waylon", "Walter", "Donald", "Ismael", "Phillip", "Iker",
    "Esteban", "Jaime", "Landyn", "Darius", "Dexter", "Matteo",
    "Colten", "Emerson", "Phoenix", "King", "Izaiah", "Karter",
    "Albert", "Jerry", "Tate", "Larry", "Saul", "Payton",
    "August", "Jalen", "Enzo", "Jay", "Rocco", "Kolton",
    "Russell", "Leon", "Philip", "Gael", "Quentin", "Tony",
    "Mathew", "Kade", "Gideon", "Dennis", "Damon", "Darren",
    "Kason", "Walker", "Jimmy", "Alberto", "Mitchell", "Alec",
    "Rodrigo", "Casey", "River", "Maverick", "Amare", "Brayan",
    "Mohamed", "Issac", "Yahir", "Arturo", "Moises", "Maximilian",
    "Knox", "Barrett", "Davis", "Gustavo", "Curtis", "Hugo",
    "Reece", "Chandler", "Mauricio", "Jamari", "Abram", "Uriel",
    "Bryant", "Archer", "Kamden", "Solomon", "Porter", "Zackary",
    "Adriel", "Ryland", "Lawrence", "Noel", "Alijah", "Ricky",
    "Ronan", "Leonel", "Maurice", "Chris", "Atticus", "Brenden",
    "Ibrahim", "Zachariah", "Khalil", "Lance", "Marvin", "Dane",
    "Bruce", "Cullen", "Orion", "Nikolas", "Pierce", "Kieran",
    "Braeden", "Kobe", "Finnegan", "Remington", "Muhammad", "Prince",
    "Orlando", "Alfredo", "Mekhi", "Sam", "Rhys", "Jacoby",
    "Eddie", "Zaiden", "Ernesto", "Joe", "Kristopher", "Jonas",
    "Gary", "Jamison", "Nico", "Johan", "Giovani", "Malcolm",
    "Armani", "Warren", "Gunnar", "Ramon", "Franklin", "Kane",
    "Byron", "Cason", "Brett", "Ari", "Deandre", "Finley",
    "Justice", "Douglas", "Cyrus", "Gianni", "Talon", "Camron",
    "Cannon", "Nash", "Dorian", "Kendrick", "Moses", "Arjun",
    "Sullivan", "Kasen", "Dominik", "Ahmed", "Korbin", "Roger",
    "Royce", "Quinton", "Salvador", "Isaias", "Skylar", "Raiden",
    "Terry", "Brodie", "Tobias", "Morgan", "Frederick", "Madden",
    "Conor", "Reese", "Braiden", "Kelvin", "Julien", "Kristian",
    "Rodney", "Wade", "Davion", "Nickolas", "Xzavier", "Alvin",
    "Asa", "Alonzo", "Ezequiel", "Boston", "Nasir", "Nelson",
    "Jase", "London", "Mohammed", "Rhett", "Jermaine", "Roy",
    "Matias", "Ace", "Chad", "Moshe", "Aarav", "Keagan",
    "Aldo", "Blaine", "Marc", "Rohan", "Bently", "Trace",
    "Kamari", "Layne", "Carmelo", "Demetrius", "Lawson", "Nathanael",
    "Uriah", "Terrance", "Ahmad", "Jamarion", "Shaun", "Kale",
    "Noe", "Carl", "Jaydon", "Callen", "Micheal", "Jaxen",
    "Lucian", "Jaxton", "Rory", "Quincy", "Guillermo", "Javon",
    "Kian", "Wilson", "Jeffery", "Joey", "Kendall", "Harper",
    "Jensen", "Mohammad", "Dayton", "Billy", "Jonathon", "Jadiel",
    "Willie", "Jadon", "Clark", "Rex", "Francis", "Kash",
    "Malakai", "Terrell", "Melvin", "Cristopher", "Layton", "Ariel",
    "Sylas", "Gerald", "Kody", "Messiah", "Semaj", "Triston",
    "Bentlee", "Lewis", "Marlon", "Tomas", "Aidyn", "Tommy",
    "Alessandro", "Isiah", "Jagger", "Nikolai", "Omari", "Sincere",
    "Cory", "Rene", "Terrence", "Harley", "Kylan", "Luciano",
    "Aron", "Felipe", "Reginald", "Tristian", "Urijah", "Beckham",
    "Jordyn", "Kayson", "Neil", "Osvaldo", "Aydin", "Ulises",
    "Deacon", "Giovanny", "Case", "Daxton", "Will", "Lee",
    "Makai", "Raphael", "Tripp", "Kole", "Channing", "Santino",
    "Stanley", "Allan", "Alonso", "Jamal", "Jorden", "Davin",
    "Soren", "Aryan", "Aydan", "Camren", "Jasiah", "Ray",
    "Ben", "Jon", "Bobby", "Darrell", "Markus", "Branden",
    "Hank", "Mathias", "Adonis", "Darian", "Jessie", "Marquis",
    "Vicente", "Zayne", "Kenny", "Raylan", "Jefferson", "Steve",
    "Wayne", "Leonard", "Kolby", "Ayaan", "Emery", "Harry",
    "Rashad", "Adrien", "Dax", "Dwayne", "Samir", "Zechariah",
    "Yusuf", "Ronnie", "Tristin", "Benson", "Memphis", "Lamar",
    "Maxim", "Bowen", "Ellis", "Javion", "Tatum", "Clay",
    "Alexzander", "Draven", "Odin", "Branson", "Elisha", "Rudy",
    "Zain", "Rayan", "Sterling", "Brennen", "Jairo", "Brendon",
    "Kareem", "Rylee", "Winston", "Jerome", "Kyson", "Lennon",
    "Luka", "Crosby", "Deshawn", "Roland", "Zavier", "Cedric",
    "Vance", "Niko", "Gauge", "Kaeden", "Killian", "Vincenzo",
    "Teagan", "Trevon", "Kymani", "Valentino", "Abdullah", "Bo",
    "Darwin", "Hamza", "Kolten", "Edison", "Jovani", "Augustus",
    "Gavyn", "Toby", "Davian", "Rogelio", "Matthias", "Brent",
    "Hayes", "Brogan", "Jamir", "Damion", "Emmitt", "Landry",
    "Chaim", "Jaylin", "Yosef", "Kamron", "Lionel", "Van",
    "Bronson", "Casen", "Junior", "Misael", "Yandel", "Alfonso",
    "Giancarlo", "Rolando", "Abdiel", "Aaden", "Deangelo", "Duncan",
    "Ishaan", "Jamie", "Maximo", "Cael", "Conrad", "Ronin",
    "Xavi", "Dominique", "Ean", "Tyrone", "Chace", "Craig",
    "Mayson", "Quintin", "Derick", "Bradyn", "Izayah", "Zachery",
    "Westin", "Alvaro", "Johnathon", "Ramiro", "Konner", "Lennox",
    "Marcelo", "Blaze", "Eugene", "Keenan", "Bruno", "Deegan",
    "Rayden", "Cale", "Camryn", "Eden", "Jamar", "Leandro",
    "Sage", "Marcel", "Jovanni", "Rodolfo", "Seamus", "Cain",
    "Damarion", "Harold", "Jaeden", "Konnor", "Jair", "Callum",
    "Rowen", "Rylen", "Arnav", "Ernest", "Gilberto", "Irvin",
    "Fisher", "Randall", "Heath", "Justus", "Lyric", "Masen",
    "Amos", "Frankie", "Harvey", "Kamryn", "Alden", "Hassan",
    "Salvatore", "Theo", "Darien", "Gilbert", "Krish", "Mike",
    "Todd", "Jaidyn", "Isai", "Samson", "Cassius", "Hezekiah",
    "Makhi", "Antoine", "Darnell", "Remy", "Stefan", "Camdyn",
    "Kyron", "Callan", "Dario", "Jedidiah", "Leonidas", "Deven",
    "Fletcher", "Sonny", "Reagan", "Yadiel", "Jerimiah", "Efrain",
    "Sidney", "Santos", "Aditya", "Brenton", "Brysen", "Nixon",
    "Tyrell", "Vaughn", "Elvis", "Freddy", "Demarcus", "Gaige",
    "Jaylon", "Gibson", "Thaddeus", "Zaire", "Coleman", "Roderick",
    "Jabari", "Zackery", "Agustin", "Alfred", "Arlo", "Braylin",
    "Leighton", "Turner", "Arian", "Clinton", "Legend", "Miller",
    "Quinten", "Mustafa", "Jakobe", "Lathan", "Otto", "Blaise",
    "Vihaan", "Enoch", "Ross", "Brice", "Houston", "Rey",
    "Benton", "Bodhi", "Graysen", "Johann", "Reuben", "Crew",
    "Darryl", "Donte", "Flynn", "Jaycob", "Jean", "Maxton",
    "Anders", "Hugh", "Ignacio", "Ralph", "Trystan", "Devan",
    "Franco", "Mariano", "Tyree", "Bridger", "Howard", "Jaydan",
    "Brecken", "Joziah", "Valentin", "Broderick", "Maxx", "Elian",
    "Eliseo", "Haiden", "Tyrese", "Zeke", "Keon", "Maksim",
    "Coen", "Cristiano", "Hendrix", "Damari", "Princeton", "Davon",
    "Deon", "Kael", "Dimitri", "Jaron", "Jaydin", "Kyan",
    "Corban", "Kingsley", "Major", "Pierre", "Yehuda", "Cayson",
    "Dangelo", "Jeramiah", "Kamren", "Kohen", "Camilo", "Cortez",
    "Keyon", "Malaki", "Ethen", "Sophia", "Isabella", "Emma",
    "Olivia", "Ava", "Emily", "Abigail", "Madison", "Mia",
    "Chloe", "Elizabeth", "Ella", "Addison", "Natalie", "Lily",
    "Grace", "Samantha", "Avery", "Sofia", "Aubrey", "Brooklyn",
    "Lillian", "Victoria", "Evelyn", "Hannah", "Alexis", "Charlotte",
    "Zoey", "Leah", "Amelia", "Zoe", "Hailey", "Layla",
    "Gabriella", "Nevaeh", "Kaylee", "Alyssa", "Anna", "Sarah",
    "Allison", "Savannah", "Ashley", "Audrey", "Taylor", "Brianna",
    "Aaliyah", "Riley", "Camila", "Khloe", "Claire", "Sophie",
    "Arianna", "Peyton", "Harper", "Alexa", "Makayla", "Julia",
    "Kylie", "Kayla", "Bella", "Katherine", "Lauren", "Gianna",
    "Maya", "Sydney", "Serenity", "Kimberly", "Mackenzie", "Autumn",
    "Jocelyn", "Faith", "Lucy", "Stella", "Jasmine", "Morgan",
    "Alexandra", "Trinity", "Molly", "Madelyn", "Scarlett", "Andrea",
    "Genesis", "Eva", "Ariana", "Madeline", "Brooke", "Caroline",
    "Bailey", "Melanie", "Kennedy", "Destiny", "Maria", "Naomi",
    "London", "Payton", "Lydia", "Ellie", "Mariah", "Aubree",
    "Kaitlyn", "Violet", "Rylee", "Lilly", "Angelina", "Katelyn",
    "Mya", "Paige", "Natalia", "Ruby", "Piper", "Annabelle",
    "Mary", "Jade", "Isabelle", "Liliana", "Nicole", "Rachel",
    "Vanessa", "Gabrielle", "Jessica", "Jordyn", "Reagan", "Kendall",
    "Sadie", "Valeria", "Brielle", "Lyla", "Isabel", "Brooklynn",
    "Reese", "Sara", "Adriana", "Aliyah", "Jennifer", "Mckenzie",
    "Gracie", "Nora", "Kylee", "Makenzie", "Izabella", "Laila",
    "Alice", "Amy", "Michelle", "Skylar", "Stephanie", "Juliana",
    "Rebecca", "Jayla", "Eleanor", "Clara", "Giselle", "Valentina",
    "Vivian", "Alaina", "Eliana", "Aria", "Valerie", "Haley",
    "Elena", "Catherine", "Elise", "Lila", "Megan", "Gabriela",
    "Daisy", "Jada", "Daniela", "Penelope", "Jenna", "Ashlyn",
    "Delilah", "Summer", "Mila", "Kate", "Keira", "Adrianna",
    "Hadley", "Julianna", "Maci", "Eden", "Josephine", "Aurora",
    "Melissa", "Hayden", "Alana", "Margaret", "Quinn", "Angela",
    "Brynn", "Alivia", "Katie", "Ryleigh", "Kinley", "Paisley",
    "Jordan", "Aniyah", "Allie", "Miranda", "Jacqueline", "Melody",
    "Willow", "Diana", "Cora", "Alexandria", "Mikayla", "Danielle",
    "Londyn", "Addyson", "Amaya", "Hazel", "Callie", "Teagan",
    "Adalyn", "Ximena", "Angel", "Kinsley", "Shelby", "Makenna",
    "Ariel", "Jillian", "Chelsea", "Alayna", "Harmony", "Sienna",
    "Amanda", "Presley", "Maggie", "Tessa", "Leila", "Hope",
    "Genevieve", "Erin", "Briana", "Delaney", "Esther", "Kathryn",
    "Ana", "Mckenna", "Camille", "Cecilia", "Lucia", "Lola",
    "Leilani", "Leslie", "Ashlynn", "Kayleigh", "Alondra", "Alison",
    "Haylee", "Carly", "Juliet", "Lexi", "Kelsey", "Eliza",
    "Josie", "Marissa", "Marley", "Alicia", "Amber", "Sabrina",
    "Kaydence", "Norah", "Allyson", "Alina", "Ivy", "Fiona",
    "Isla", "Nadia", "Kyleigh", "Christina", "Emery", "Laura",
    "Cheyenne", "Alexia", "Emerson", "Sierra", "Luna", "Cadence",
    "Daniella", "Fatima", "Bianca", "Cassidy", "Veronica", "Kyla",
    "Evangeline", "Karen", "Adeline", "Jazmine", "Mallory", "Rose",
    "Jayden", "Kendra", "Camryn", "Macy", "Abby", "Dakota",
    "Mariana", "Gia", "Adelyn", "Madilyn", "Jazmin", "Iris",
    "Nina", "Georgia", "Lilah", "Breanna", "Kenzie", "Jayda",
    "Phoebe", "Lilliana", "Kamryn", "Athena", "Malia", "Nyla",
    "Miley", "Heaven", "Audrina", "Madeleine", "Kiara", "Selena",
    "Maddison", "Giuliana", "Emilia", "Lyric", "Joanna", "Adalynn",
    "Annabella", "Fernanda", "Aubrie", "Heidi", "Esmeralda", "Kira",
    "Elliana", "Arabella", "Kelly", "Karina", "Paris", "Caitlyn",
    "Kara", "Raegan", "Miriam", "Crystal", "Alejandra", "Tatum",
    "Savanna", "Tiffany", "Ayla", "Carmen", "Maliyah", "Karla",
    "Bethany", "Guadalupe", "Kailey", "Macie", "Gemma", "Noelle",
    "Rylie", "Elaina", "Lena", "Amiyah", "Ruth", "Ainsley",
    "Finley", "Danna", "Parker", "Emely", "Jane", "Joselyn",
    "Scarlet", "Anastasia", "Journey", "Angelica", "Sasha", "Yaretzi",
    "Charlie", "Juliette", "Lia", "Brynlee", "Angelique", "Katelynn",
    "Nayeli", "Vivienne", "Addisyn", "Kaelyn", "Annie", "Tiana",
    "Kyra", "Janelle", "Cali", "Aleah", "Caitlin", "Imani",
    "Jayleen", "April", "Julie", "Alessandra", "Julissa", "Kailyn",
    "Jazlyn", "Janiyah", "Kaylie", "Madelynn", "Baylee", "Itzel",
    "Monica", "Adelaide", "Brylee", "Michaela", "Madisyn", "Cassandra",
    "Elle", "Kaylin", "Aniya", "Dulce", "Olive", "Jaelyn",
    "Courtney", "Brittany", "Madalyn", "Jasmin", "Kamila", "Kiley",
    "Tenley", "Braelyn", "Holly", "Helen", "Hayley", "Carolina",
    "Cynthia", "Talia", "Anya", "Estrella", "Bristol", "Jimena",
    "Harley", "Jamie", "Rebekah", "Charlee", "Lacey", "Jaliyah",
    "Cameron", "Sarai", "Caylee", "Kennedi", "Dayana", "Tatiana",
    "Serena", "Eloise", "Daphne", "Mckinley", "Mikaela", "Celeste",
    "Hanna", "Lucille", "Skyler", "Nylah", "Camilla", "Lilian",
    "Lindsey", "Sage", "Viviana", "Danica", "Liana", "Melany",
    "Aileen", "Lillie", "Kadence", "Zariah", "June", "Lilyana",
    "Bridget", "Anabelle", "Lexie", "Anaya", "Skye", "Alyson",
    "Angie", "Paola", "Elsie", "Erica", "Gracelyn", "Kiera",
    "Myla", "Aylin", "Lana", "Priscilla", "Kassidy", "Natasha",
    "Nia", "Kenley", "Dylan", "Kali", "Ada", "Miracle",
    "Raelynn", "Briella", "Emilee", "Lorelei", "Francesca", "Arielle",
    "Madyson", "Amira", "Jaelynn", "Nataly", "Annika", "Joy",
    "Alanna", "Shayla", "Brenna", "Sloane", "Vera", "Abbigail",
    "Amari", "Jaycee", "Lauryn", "Skyla", "Whitney", "Aspen",
    "Johanna", "Jaylah", "Nathalie", "Laney", "Logan", "Brinley",
    "Leighton", "Marlee", "Ciara", "Justice", "Brenda", "Kayden",
    "Erika", "Elisa", "Lainey", "Rowan", "Annabel", "Teresa",
    "Dahlia", "Janiya", "Lizbeth", "Nancy", "Aleena", "Kaliyah",
    "Farrah", "Marilyn", "Eve", "Anahi", "Rosalie", "Jaylynn",
    "Bailee", "Emmalyn", "Madilynn", "Lea", "Sylvia", "Annalise",
    "Averie", "Yareli", "Zoie", "Samara", "Amani", "Regina",
    "Hailee", "Arely", "Evelynn", "Luciana", "Natalee", "Anika",
    "Liberty", "Giana", "Haven", "Gloria", "Gwendolyn", "Jazlynn",
    "Marisol", "Ryan", "Virginia", "Myah", "Elsa", "Selah",
    "Melina", "Aryanna", "Adelynn", "Raelyn", "Miah", "Sariah",
    "Kaylynn", "Amara", "Helena", "Jaylee", "Maeve", "Raven",
    "Linda", "Anne", "Desiree", "Madalynn", "Meredith", "Clarissa",
    "Elyse", "Marie", "Alissa", "Anabella", "Hallie", "Denise",
    "Elisabeth", "Kaia", "Danika", "Kimora", "Milan", "Claudia",
    "Dana", "Siena", "Zion", "Ansley", "Sandra", "Cara",
    "Halle", "Maleah", "Marina", "Saniyah", "Casey", "Harlow",
    "Kassandra", "Charley", "Rosa", "Shiloh", "Tori", "Adele",
    "Kiana", "Ariella", "Jaylene", "Joslyn", "Kathleen", "Aisha",
    "Amya", "Ayanna", "Isis", "Karlee", "Cindy", "Perla",
    "Janessa", "Lylah", "Raquel", "Zara", "Evie", "Phoenix",
    "Catalina", "Lilianna", "Mollie", "Simone", "Briley", "Bria",
    "Kristina", "Lindsay", "Rosemary", "Cecelia", "Kourtney", "Aliya",
    "Asia", "Elin", "Isabela", "Kristen", "Yasmin", "Alani",
    "Aiyana", "Amiya", "Felicity", "Patricia", "Kailee", "Adrienne",
    "Aliana", "Ember", "Mariyah", "Mariam", "Ally", "Bryanna",
    "Tabitha", "Wendy", "Sidney", "Clare", "Aimee", "Laylah",
    "Maia", "Karsyn", "Greta", "Noemi", "Jayde", "Kallie",
    "Leanna", "Irene", "Jessie", "Paityn", "Kaleigh", "Lesly",
    "Gracelynn", "Amelie", "Iliana", "Elaine", "Lillianna", "Ellen",
    "Taryn", "Lailah", "Rylan", "Lisa", "Emersyn", "Braelynn",
    "Shannon", "Beatrice", "Heather", "Jaylin", "Taliyah", "Arya",
    "Emilie", "Ali", "Janae", "Chaya", "Cherish", "Jaida",
    "Journee", "Sawyer", "Destinee", "Emmalee", "Ivanna", "Charli",
    "Jocelynn", "Kaya", "Elianna", "Armani", "Kaitlynn", "Rihanna",
    "Reyna", "Christine", "Alia", "Leyla", "Mckayla", "Celia",
    "Raina", "Alayah", "Macey", "Meghan", "Zaniyah", "Carolyn",
    "Kynlee", "Carlee", "Alena", "Bryn", "Jolie", "Carla",
    "Eileen", "Keyla", "Saniya", "Livia", "Amina", "Angeline",
    "Krystal", "Zaria", "Emelia", "Renata", "Mercedes", "Paulina",
    "Diamond", "Jenny", "Aviana", "Ayleen", "Barbara", "Alisha",
    "Jaqueline", "Maryam", "Julianne", "Matilda", "Sonia", "Edith",
    "Martha", "Audriana", "Kaylyn", "Emmy", "Giada", "Tegan",
    "Charleigh", "Haleigh", "Nathaly", "Susan", "Kendal", "Leia",
    "Jordynn", "Amirah", "Giovanna", "Mira", "Addilyn", "Frances",
    "Kaitlin", "Kyndall", "Myra", "Abbie", "Samiyah", "Taraji",
    "Braylee", "Corinne", "Jazmyn", "Kaiya", "Lorelai", "Abril",
    "Kenya", "Mae", "Hadassah", "Alisson", "Haylie", "Brisa",
    "Deborah", "Mina", "Rayne", "America", "Ryann", "Milania",
    "Pearl", "Blake", "Millie", "Deanna", "Araceli", "Demi",
    "Gisselle", "Paula", "Karissa", "Sharon", "Kensley", "Rachael",
    "Aryana", "Chanel", "Natalya", "Hayleigh", "Paloma", "Avianna",
    "Jemma", "Moriah", "Renee", "Alyvia", "Zariyah", "Hana",
    "Judith", "Kinsey", "Salma", "Kenna", "Mara", "Patience",
    "Saanvi", "Cristina", "Dixie", "Kaylen", "Averi", "Carlie",
    "Kirsten", "Lilyanna", "Charity", "Larissa", "Zuri", "Chana",
    "Ingrid", "Lina", "Tianna", "Lilia", "Marisa", "Nahla",
    "Sherlyn", "Adyson", "Cailyn", "Princess", "Yoselin", "Aubrianna",
    "Maritza", "Rayna", "Luz", "Cheyanne", "Azaria", "Jacey",
    "Roselyn", "Elliot", "Jaiden", "Tara", "Alma", "Esperanza",
    "Jakayla", "Yesenia", "Kiersten", "Marlene", "Nova", "Adelina",
    "Ayana", "Kai", "Nola", "Sloan", "Avah", "Carley",
    "Meadow", "Neveah", "Tamia", "Alaya", "Jadyn", "Sanaa",
    "Kailynn", "Diya", "Rory", "Abbey", "Karis", "Maliah",
    "Belen", "Bentley", "Jaidyn", "Shania", "Britney", "Yazmin",
    "Aubri", "Malaya", "Micah", "River", "Alannah", "Jolene",
    "Shaniya", "Tia", "Yamilet", "Bryleigh", "Carissa", "Karlie",
    "Libby", "Lilith", "Lara", "Tess", "Aliza", "Laurel",
    "Kaelynn", "Leona", "Regan", "Yaritza", "Kasey", "Mattie",
    "Audrianna", "Blakely", "Campbell", "Dorothy", "Julieta", "Kylah",
    "Kyndal", "Temperance", "Tinley", "Akira", "Saige", "Ashtyn",
    "Jewel", "Kelsie", "Miya", "Cambria", "Analia", "Janet",
    "Kairi", "Aleigha", "Bree", "Dalia", "Liv", "Sarahi",
    "Yamileth", "Carleigh", "Geraldine", "Izabelle", "Riya", "Samiya",
    "Abrielle", "Annabell", "Leigha", "Pamela", "Caydence", "Joyce",
    "Juniper", "Malaysia", "Isabell", "Blair", "Jaylyn", "Marianna",
    "Rivka", "Alianna", "Gwyneth", "Kendyl", "Sky", "Esme",
    "Jaden", "Sariyah", "Stacy", "Kimber", "Kamille", "Milagros",
    "Karly", "Karma", "Thalia", "Willa", "Amalia", "Hattie",
    "Payten", "Anabel", "Ann", "Galilea", "Milana", "Yuliana",
    "Damaris");

my @surnames = ("Smith", "Johnson", "Williams", "Jones", "Brown", "Davis", "Miller",
    "Wilson", "Moore", "Taylor", "Anderson", "Thomas", "Jackson", "White",
    "Harris", "Martin", "Thompson", "Garcia", "Martinez", "Robinson", "Clark",
    "Rodriguez", "Lewis", "Lee", "Walker", "Hall", "Allen", "Young", "Griffin",
    "Hernandez", "King", "Wright", "Lopez", "Hill", "Scott", "Green",
    "Adams", "Baker", "Gonzalez", "Nelson", "Carter", "Mitchell", "Perez",
    "Roberts", "Turner", "Phillips", "Campbell", "Parker", "Evans", "Edwards",
    "Collins", "Stewart", "Sanchez", "Morris", "Rogers", "Reed", "Cook",
    "Morgan", "Bell", "Murphy", "Bailey", "Rivera", "Cooper", "Richardson",
    "Cox", "Howard", "Ward", "Torres", "Peterson", "Gray", "Ramirez",
    "James", "Watson", "Brooks", "Kelly", "Sanders", "Price", "Bennett",
    "Wood", "Barnes", "Ross", "Henderson", "Coleman", "Jenkins", "Perry",
    "Powell", "Long", "Patterson", "Hughes", "Flores", "Washington", "Butler",
    "Simmons", "Foster", "Gonzales", "Bryant", "Alexander", "Russell",
    "Diaz", "Hayes", "Myers", "Ford", "Hamilton", "Graham", "Sullivan",
    "Wallace", "Woods", "Cole", "West", "Jordan", "Owens", "Reynolds",
    "Fisher", "Ellis", "Harrison", "Gibson", "Mcdonald", "Cruz", "Marshall",
    "Ortiz", "Gomez", "Murray", "Freeman", "Wells", "Webb", "Simpson",
    "Stevens", "Tucker", "Porter", "Hunter", "Hicks", "Crawford", "Henry",
    "Boyd", "Mason", "Morales", "Kennedy", "Warren", "Dixon", "Ramos",
    "Reyes", "Burns", "Gordon", "Shaw", "Holmes", "Rice", "Robertson",
    "Hunt", "Black", "Daniels", "Palmer", "Mills", "Nichols", "Grant",
    "Knight", "Ferguson", "Rose", "Stone", "Hawkins", "Dunn", "Perkins",
    "Hudson", "Spencer", "Gardner", "Stephens", "Payne", "Pierce", "Berry",
    "Matthews", "Arnold", "Wagner", "Willis", "Ray", "Watkins", "Olson",
    "Carroll", "Duncan", "Snyder", "Hart", "Cunningham", "Bradley", "Lane",
    "Andrews", "Ruiz", "Harper", "Fox", "Riley", "Armstrong", "Carpenter",
    "Weaver", "Greene", "Lawrence", "Elliott", "Chavez", "Sims", "Austin",
    "Peters", "Kelley", "Franklin", "Lawson", "Fields", "Gutierrez", "Ryan",
    "Schmidt", "Carr", "Vasquez", "Castillo", "Wheeler", "Chapman", "Oliver",
    "Montgomery", "Richards", "Williamson", "Johnston", "Banks", "Meyer",
    "Mccoy", "Howell", "Alvarez", "Morrison", "Hansen", "Fernandez", "Garza",
    "Harvey", "Little", "Burton", "Stanley", "Nguyen", "George", "Jacobs",
    "Reid", "Kim", "Fuller", "Lynch", "Dean", "Gilbert", "Garrett", "Bishop",
    "Romero", "Welch", "Larson", "Frazier", "Burke", "Hanson", "Day",
    "Mendoza", "Moreno", "Bowman", "Medina", "Fowler", "Brewer", "Hoffman",
    "Carlson", "Silva", "Pearson", "Holland", "Douglas", "Fleming", "Jensen",
    "Vargas", "Byrd", "Davidson", "Hopkins", "May", "Terry", "Herrera",
    "Wade", "Soto", "Walters", "Curtis", "Neal", "Caldwell", "Lowe",
    "Jennings", "Barnett", "Graves", "Jimenez", "Horton", "Shelton", "Barrett",
    "Obrien", "Castro", "Sutton", "Gregory", "Mckinney", "Lucas", "Miles",
    "Craig", "Rodriquez", "Chambers", "Holt", "Lambert", "Fletcher", "Watts",
    "Bates", "Hale", "Rhodes", "Pena", "Beck", "Newman", "Haynes",
    "Mcdaniel", "Mendez", "Bush", "Vaughn", "Parks", "Dawson", "Santiago",
    "Norris", "Hardy", "Love", "Steele", "Curry", "Powers", "Schultz",
    "Barker", "Guzman", "Page", "Munoz", "Ball", "Keller", "Chandler",
    "Weber", "Leonard", "Walsh", "Lyons", "Ramsey", "Wolfe", "Schneider",
    "Mullins", "Benson", "Sharp", "Bowen", "Daniel", "Barber", "Cummings",
    "Hines", "Baldwin", "Griffith", "Valdez", "Hubbard", "Salazar", "Reeves",
    "Warner", "Stevenson", "Burgess", "Santos", "Tate", "Cross", "Garner",
    "Mann", "Mack", "Moss", "Thornton", "Dennis", "Mcgee", "Farmer",
    "Delgado", "Aguilar", "Vega", "Glover", "Manning", "Cohen", "Harmon",
    "Rodgers", "Robbins", "Newton", "Todd", "Blair", "Higgins", "Ingram",
    "Reese", "Cannon", "Strickland", "Townsend", "Potter", "Goodwin", "Walton",
    "Rowe", "Hampton", "Ortega", "Patton", "Swanson", "Joseph", "Francis",
    "Goodman", "Maldonado", "Yates", "Becker", "Erickson", "Hodges", "Rios",
    "Conner", "Adkins", "Webster", "Norman", "Malone", "Hammond", "Flowers",
    "Cobb", "Moody", "Quinn", "Blake", "Maxwell", "Pope", "Floyd", "Sandoval",
    "Osborne", "Paul", "Mccarthy", "Guerrero", "Lindsey", "Estrada",
    "Gibbs", "Tyler", "Gross", "Fitzgerald", "Stokes", "Doyle", "Sherman",
    "Saunders", "Wise", "Colon", "Gill", "Alvarado", "Greer", "Padilla",
    "Simon", "Waters", "Nunez", "Ballard", "Schwartz", "Mcbride", "Houston",
    "Christensen", "Klein", "Pratt", "Briggs", "Parsons", "Mclaughlin",
    "French", "Buchanan", "Moran", "Copeland", "Roy", "Pittman", "Brady",
    "Mccormick", "Holloway", "Brock", "Poole", "Frank", "Logan", "Owen",
    "Bass", "Marsh", "Drake", "Wong", "Jefferson", "Park", "Morton",
    "Abbott", "Sparks", "Patrick", "Norton", "Huff", "Clayton", "Massey",
    "Lloyd", "Figueroa", "Carson", "Bowers", "Roberson", "Barton", "Tran",
    "Lamb", "Harrington", "Casey", "Boone", "Cortez", "Clarke", "Mathis",
    "Singleton", "Wilkins", "Cain", "Bryan", "Underwood", "Hogan", "Mckenzie",
    "Collier", "Luna", "Phelps", "Mcguire", "Allison", "Bridges", "Wilkerson",
    "Nash", "Summers", "Atkins", "Wilcox", "Pitts", "Conley", "Marquez",
    "Burnett", "Richard", "Cochran", "Chase", "Davenport", "Hood", "Gates",
    "Clay", "Ayala", "Sawyer", "Roman", "Vazquez", "Dickerson", "Hodge",
    "Acosta", "Flynn", "Espinoza", "Nicholson", "Monroe", "Wolf", "Morrow",
    "Kirk", "Randall", "Anthony", "Whitaker", "Oconnor", "Skinner", "Ware",
    "Molina", "Kirby", "Huffman", "Bradford", "Charles", "Gilmore",
    "Oneal", "Bruce", "Lang", "Combs", "Kramer", "Heath", "Hancock",
    "Gallagher", "Gaines", "Shaffer", "Short", "Wiggins", "Mathews", "Mcclain",
    "Fischer", "Wall", "Small", "Melton", "Hensley", "Bond", "Dyer",
    "Cameron", "Grimes", "Contreras", "Christian", "Wyatt", "Baxter", "Snow",
    "Mosley", "Shepherd", "Larsen", "Hoover", "Beasley", "Glenn", "Petersen",
    "Whitehead", "Meyers", "Keith", "Garrison", "Vincent", "Shields", "Horn",
    "Savage", "Olsen", "Schroeder", "Hartman", "Woodard", "Mueller", "Kemp",
    "Deleon", "Booth", "Patel", "Calhoun", "Wiley", "Eaton", "Cline",
    "Navarro", "Harrell", "Lester", "Humphrey", "Parrish", "Duran",
    "Hutchinson", "Zimmerman", "Dominguez", "Mcintosh", "Raymond",
    "Hess", "Dorsey", "Bullock", "Robles", "Beard", "Dalton", "Avila",
    "Vance", "Rich", "Blackwell", "York", "Johns", "Blankenship", "Trevino",
    "Salinas", "Campos", "Pruitt", "Moses", "Callahan", "Golden", "Montoya",
    "Hardin", "Guerra", "Mcdowell", "Carey", "Stafford", "Gallegos", "Henson",
    "Wilkinson", "Booker", "Merritt", "Miranda", "Atkinson", "Orr", "Decker",
    "Hobbs", "Preston", "Tanner", "Knox", "Pacheco", "Stephenson", "Glass",
    "Rojas", "Serrano", "Marks", "Hickman", "English", "Sweeney", "Strong",
    "Prince", "Mcclure", "Conway", "Walter", "Roth", "Maynard", "Farrell",
    "Lowery", "Hurst", "Nixon", "Weiss", "Trujillo", "Ellison", "Sloan",
    "Juarez", "Winters", "Mclean", "Randolph", "Leon", "Boyer", "Villarreal",
    "Mccall", "Gentry", "Carrillo", "Kent", "Ayers", "Lara", "Shannon",
    "Sexton", "Pace", "Hull", "Leblanc", "Browning", "Velasquez", "Leach",
    "Chang", "House", "Sellers", "Herring", "Noble", "Foley", "Bartlett",
    "Mercado", "Landry", "Durham", "Walls", "Barr", "Mckee", "Bauer",
    "Rivers", "Everett", "Bradshaw", "Pugh", "Velez", "Rush", "Estes",
    "Dodson", "Morse", "Sheppard", "Weeks", "Camacho", "Bean", "Barron",
    "Livingston", "Middleton", "Spears", "Branch", "Blevins", "Chen", "Kerr",
    "Mcconnell", "Hatfield", "Harding", "Ashley", "Solis", "Herman", "Frost",
    "Giles", "Blackburn", "William", "Pennington", "Woodward", "Finley",
    "Koch", "Best", "Solomon", "Mccullough", "Dudley", "Nolan", "Blanchard",
    "Rivas", "Brennan", "Mejia", "Kane", "Benton", "Joyce", "Buckley",
    "Haley", "Valentine", "Maddox", "Russo", "Mcknight", "Buck", "Moon",
    "Mcmillan", "Crosby", "Berg", "Dotson", "Mays", "Roach", "Church",
    "Chan", "Richmond", "Meadows", "Faulkner", "Oneill", "Knapp", "Kline",
    "Barry", "Ochoa", "Jacobson", "Gay", "Avery", "Hendricks", "Horne",
    "Shepard", "Hebert", "Cherry", "Cardenas", "Mcintyre", "Whitney", "Waller",
    "Holman", "Donaldson", "Cantu", "Terrell", "Morin", "Gillespie", "Fuentes",
    "Tillman", "Sanford", "Bentley", "Peck", "Key", "Salas", "Rollins",
    "Gamble", "Dickson", "Battle", "Santana", "Cabrera", "Cervantes", "Howe",
    "Hinton", "Hurley", "Spence", "Zamora", "Yang", "Mcneil", "Suarez",
    "Case", "Petty", "Gould", "Mcfarland", "Sampson", "Carver", "Bray",
    "Rosario", "Macdonald", "Stout", "Hester", "Melendez", "Dillon", "Farley",
    "Hopper", "Galloway", "Potts", "Bernard", "Joyner", "Stein", "Aguirre",
    "Osborn", "Mercer", "Bender", "Franco", "Rowland", "Sykes", "Benjamin",
    "Travis", "Pickett", "Crane", "Sears", "Mayo", "Dunlap", "Hayden",
    "Wilder", "Mckay", "Coffey", "Mccarty", "Ewing", "Cooley", "Vaughan",
    "Bonner", "Cotton", "Holder", "Stark", "Ferrell", "Cantrell", "Fulton",
    "Lynn", "Lott", "Calderon", "Rosa", "Pollard", "Hooper", "Burch",
    "Mullen", "Fry", "Riddle", "Levy", "David", "Duke", "Odonnell",
    "Guy", "Michael", "Britt", "Frederick", "Daugherty", "Berger", "Dillard",
    "Alston", "Jarvis", "Frye", "Riggs", "Chaney", "Odom", "Duffy",
    "Fitzpatrick", "Valenzuela", "Merrill", "Mayer", "Alford", "Mcpherson",
    "Acevedo", "Donovan", "Barrera", "Albert", "Cote", "Reilly", "Compton",
    "Mooney", "Mcgowan", "Craft", "Cleveland", "Clemons", "Wynn", "Nielsen",
    "Baird", "Stanton", "Snider", "Rosales", "Bright", "Witt", "Stuart",
    "Hays", "Holden", "Rutledge", "Kinney", "Clements", "Castaneda", "Slater",
    "Hahn", "Emerson", "Conrad", "Burks", "Delaney", "Pate", "Lancaster",
    "Sweet", "Justice", "Tyson", "Sharpe", "Whitfield", "Talley", "Macias",
    "Irwin", "Burris", "Ratliff", "Mccray", "Madden", "Kaufman", "Beach",
    "Goff", "Cash", "Bolton", "Mcfadden", "Levine", "Good", "Byers",
    "Kirkland", "Kidd", "Workman", "Carney", "Dale", "Mcleod", "Holcomb",
    "England", "Finch", "Head", "Burt", "Hendrix", "Sosa", "Haney",
    "Franks", "Sargent", "Nieves", "Downs", "Rasmussen", "Bird", "Hewitt",
    "Lindsay", "Le", "Foreman", "Valencia", "Oneil", "Delacruz", "Vinson",
    "Dejesus", "Hyde", "Forbes", "Gilliam", "Guthrie", "Wooten", "Huber",
    "Barlow", "Boyle", "Mcmahon", "Buckner", "Rocha", "Puckett", "Langley",
    "Knowles", "Cooke", "Velazquez", "Whitley", "Noel", "Vang");

my @companies = ("Apple_Inc.","Google_Inc.","IBM","McDonald's","Microsoft","The_Coca-Cola_Company","AT&T","Philip_Morris_International","China_Mobile","GE","ICBC","Vodafone","Verizon","Amazon","Wal-Mart","Wells_Fargo","UPS","Hewlett-Packard","T-Mobile","Visa","Movistar","Oracle","SAP","China_Construction","BlackBerry","Louis_Vuitton","Toyota","HSBC","Baidu","BMW","Tesco","Gillette","China_Life","Pampers","Facebook","Orange","Bank_of_China","Disney","RBC","American_Express","ExxonMobil","Toronto-Dominion","Agri._Bk_China","Cisco","Budweiser","L'Oréal","Citibank","NTT_Docomo","Accenture","Mercedes-Benz","Shell","Tencent","ICICI","Subway","Colgate","Honda","Nike","Intel","Carrefour","MasterCard","Petrobras","H&M","Pepsi","BP","Target","Porsche","Samsung","Chase","Standard_Chartered","Siemens","Hermès","Starbucks","FedEx","Telecom_Italia","Telcel","Santander","PetroChina","Nintendo","MTS","Nokia","eBay","Ping_An","U.S._Bancorp","Sony","Zara","Scotiabank","Nissan","Home_Depot","Paff-Dreams","China_Telecom","Bank_of_America","Red_Bull","Aldi","TIM","Barclays","China_Merchants","Bradesco","Goldman_Sachs");

my @animals = ("aardvark","addax","alligator","alpaca","anteater","antelope","aoudad","ape","argali","armadillo","ass","baboon","badger","basilisk","bat","bear","beaver","bighorn","bison","boar","budgerigar","buffalo","bull","bunny","burro","camel","canary","capybara","cat","chameleon","chamois","cheetah","chimpanzee","chinchilla","chipmunk","civet","coati","colt","cony","cougar","cow","coyote","crocodile","crow","deer","dingo","doe","dog","donkey","dormouse","dromedary","duckbill","dugong","eland","elephant","elk","ermine","ewe","fawn","ferret","finch","fish","fox","frog","gazelle","gemsbok","gila_monster","giraffe","gnu","goat","gopher","gorilla","grizzly_bear","ground_hog","guanaco","guinea_pig","hamster","hare","hartebeest","hedgehog","hippopotamus","hog","horse","hyena","ibex","iguana","impala","jackal","jaguar","jerboa","kangaroo","kid","kinkajou","kitten","koala","koodoo","lamb","lemur","leopard","lion","lizard","llama","lovebird","lynx","mandrill","mare","marmoset","marten","mink","mole","mongoose","monkey","moose","mountain_goat","mouse","mule","musk_deer","musk-ox","muskrat","mustang","mynah_bird","newt","ocelot","okapi","opossum","orangutan","oryx","otter","ox","panda","panther","parakeet","parrot","peccary","pig","platypus","polar_bear","pony","porcupine","porpoise","prairie_dog","pronghorn","puma","puppy","quagga","rabbit","raccoon","ram","rat","reindeer","reptile","rhinoceros","roebuck","salamander","seal","sheep","shrew","silver_fox","skunk","sloth","snake","springbok","squirrel","stallion","steer","tapir","tiger","toad","turtle","vicuna","walrus","warthog","waterbuck","weasel","whale","wildcat","wolf","wolverine","wombat","woodchuck","yak","zebra","zebu");

my @countries = ("Afghanistan", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Anguilla", "Antigua and Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bermuda", "Bhutan", "Bolivia", "Bosnia-Herzegovina", "Botswana", "Bouvet Island", "Brazil", "Brunei", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia", "Cameroon", "Canada", "Cape Verde", "Cayman Islands", "Central African Republic", "Chad", "Chile", "China", "Christmas Island", "Cocos  Islands", "Colombia", "Comoros", "Congo, Democratic Republic of the", "Congo, Republic of", "Cook Islands", "Costa Rica", "Croatia", "Cuba", "Cyprus", "Czech Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Falkland Islands", "Faroe Islands", "Fiji", "Finland", "France", "French Guiana", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Gibraltar", "Greece", "Greenland", "Grenada", "Guadeloupe", "Guam", "Guatemala", "Guinea", "Guinea Bissau", "Guyana", "Haiti", "Holy See", "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy", "Ivory Coast", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Macau", "Macedonia", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Martinique", "Mauritania", "Mauritius", "Mayotte", "Mexico", "Micronesia", "Moldova", "Monaco", "Mongolia", "Montenegro", "Montserrat", "Morocco", "Mozambique", "Myanmar", "Namibia", "Nauru", "Nepal", "Netherlands", "Netherlands Antilles", "New Caledonia", "New Zealand", "Nicaragua", "Niger", "Nigeria", "Niue", "Norfolk Island", "North Korea", "Northern Mariana Islands", "Norway", "Oman", "Pakistan", "Palau", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Pitcairn Island", "Poland", "Polynesia", "Portugal", "Puerto Rico", "Qatar", "Reunion", "Romania", "Russia", "Rwanda", "Saint Helena", "Saint Kitts and Nevis", "Saint Lucia", "Saint Pierre and Miquelon", "Saint Vincent and Grenadines", "Samoa", "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Georgia and South Sandwich Islands", "South Korea", "South Sudan", "Spain", "Sri Lanka", "Sudan", "Suriname", "Svalbard and Jan Mayen Islands", "Swaziland", "Sweden", "Switzerland", "Syria", "Taiwan", "Tajikistan", "Tanzania", "Thailand", "Timor-Leste", "Togo", "Tokelau", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Turks and Caicos Islands", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela", "Vietnam", "Virgin Islands", "Wallis and Futuna Islands", "Yemen", "Zambia", "Zimbabwe");

my @quote = ("You\'ve gotta dance like there\'s nobody watching, Love like you\'ll never be hurt, Sing like there\'s nobody listening, And live like it\'s heaven on earth.", "Be the change that you wish to see in the world.", "Imperfection is beauty, madness is genius and it\'s better to be absolutely ridiculous than absolutely boring.", "Listen to the mustn\'ts, child. Listen to the don\'ts. Listen to the shouldn\'ts, the impossibles, the won\'ts. Listen to the never haves, then listen close to me… Anything can happen, child. Anything can be.", "I believe in pink. I believe that laughing is the best calorie burner. I believe in kissing, kissing a lot. I believe in being strong when everything seems to be going wrong. I believe that happy girls are the prettiest girls. I believe that tomorrow is another day and I believe in miracles.", "Our deepest fear is not that we are inadequate. Our deepest fear is that we are powerful beyond measure. It is our light, not our darkness that most frightens us. We ask ourselves, ‘Who am I to be brilliant, gorgeous, talented, fabulous?\' Actually, who are you not to be?", "And, when you want something, all the universe conspires in helping you to achieve it.", "the only people for me are the mad ones, the ones who are mad to live, mad to talk, mad to be saved, desirous of everything at the same time, the ones who never yawn or say a commonplace thing, but burn, burn, burn like fabulous yellow roman candles exploding like spiders across the stars.", "Hope is the thing with feathers That perches in the soul And sings the tune without the words And never stops at all.", "Do not go where the path may lead, go instead where there is no path and leave a trail.", "None but ourselves can free our minds.", "So we beat on, boats against the current, borne back ceaselessly into the past.", "Simplicity, patience, compassion. These three are your greatest treasures. Simple in actions and thoughts, you return to the source of being. Patient with both friends and enemies, you accord with the way things are. Compassionate toward yourself, you reconcile all beings in the world.", "A ship is safe in harbor, but that\'s not what ships are for.", "Meditate. Live purely. Be quiet. Do your work with mastery. Like the moon, come out from behind the clouds! Shine.", "Is it so bad, then, to be misunderstood? Pythagoras was misunderstood, and Socrates, and Jesus, and Luther, and Copernicus, and Galileo, and Newton, and every pure and wise spirit that ever took flesh. To be great is to be misunderstood.", "Be patient toward all that is unsolved in your heart and to try to love the questions themselves like locked rooms and like books that are written in a very foreign tongue. Do not now seek the answers, which cannot be given you because you would not be able to live them. And the point is,to live everything. Live the questions now. Perhaps you win then gradually, without noticing it, live along some distant day into the answer.", "I don\'t think I could love you so much if you had nothing to complain of and nothing to regret. I don\'t like people who have never fallen or stumbled. Their virtue is lifeless and of little value. Life hasn\'t revealed it\'s beauty to them.", "Tell me, what is it you plan to do with your one wild and precious life?", "Only those who will risk going too far can possibly find out how far one can go.", "It\'s not the load that breaks you down, it\'s the way you carry it.", "Hold fast to dreams, For if dreams die Life is a broken-winged bird, That cannot fly.", "Understanding is the first step to acceptance, and only with acceptance can there be recovery.", "Your life is an occasion. Rise to it.", "It is not revolutions and upheavals That clear the road to new and better days, But revelations, lavishness and torments Of someone\'s soul, inspired and ablaze.", "It\'s so hard to forget pain, but it\'s even harder to remember sweetness. We have no scar to show for happiness. We learn so little from peace.", "Count your age by friends, not years. Count your life by smiles, not tears.", "With all its sham, drudgery, and broken dreams, it is still a beautiful world. Be cheerful. Strive to be happy.", "Believe in yourself and all that you are. Know that there is something inside you that is greater than any obstacle.", "All the world is made of faith, and trust, and pixie dust.", "And those who were seen dancing were thought to be insane by those who could not hear the music.", "I do not believe this darkness will endure.", "Rather than love, than money, than fame, give me truth.", "You must have chaos within you to give birth to a dancing star.", "Do not feel lonely, the entire universe is within you.", "All we have is all we need. All we need is the awareness of how blessed we really are.", "The bad news is you\'re falling through the air, nothing to hang on to, no parachute. The good news is, there\'s no ground.", "In the midst of winter, I found there was within me an invincible summer.", "be gentle with yourself. You are a child of the universe, no less than the trees and the stars; you have a right to be here.", "There are far, far better things ahead than any we leave behind.", "All that is gold does not glitter, not all those who wander are lost", "The most beautiful people we have known are those who have known defeat, known suffering, known struggle, known loss, and have found their way out of the depths. These persons have an appreciation, a sensitivity, and an understanding of life that fills them with compassion, gentleness, and a deep loving concern. Beautiful people do not just happen.", "Whatever you are, be a good one", "Promise me you\'ll always remember: You\'re braver than you believe, and stronger than you seem, and smarter than you think.", "Out of suffering have emerged the strongest souls; the most massive characters are seared with scars.", "Ever tried. Ever failed. No matter. Try Again. Fail again. Fail better.", "Live, travel, adventure, bless, and don\'t be sorry.", "We work in the dark – we do what we can – we give what we have. Our doubt is our passion, and our passion is our task. The rest is the madness of art.", "If you have built castles in the air, your work need not be lost; that is where they should be. Now put foundations under them.", "Don\'t tell me the moon is shining; show me the glint of light on broken glass.", "When it\'s over, I want to say: all my life I was a bride married to amazement. I was the bridegroom, taking the world into my arms. When it is over, I don\'t want to wonder if I have made of my life something particular, and real. I don\'t want to find myself sighing and frightened, or full of argument. I don\'t want to end up simply having visited this world.", "Don\'t step into lives that aren\'t yours, make choices that aren\'t nourishing, or dance stiffly for years with the wrong partner, or parts of yourself.", "Emotional discomfort, when accepted, rises, crests and falls in a series of waves. Each wave washes a part of us away and deposits treasures we never imagined. Out goes naivete, in comes wisdom; out goes anger, in comes discernment; out goes despair, in comes kindness. No one would call it easy, but the rhythm of emotional pain that we learn to tolerate is natural, constructive and expansive… The pain leaves you healthier than it found you.", "There shall be an eternal summer in the grateful heart.", "Never stop dreaming of moonbeams and fairy dust, shiny stars and the wonder of the heavens, a happier life and a better world.", "Here\'s to the crazy ones, the misfits, the rebels, the troublemakers, the round pegs in the square holes… the ones who see things differently — they\'re not fond of rules… You can quote them, disagree with them, glorify or vilify them, but the only thing you can\'t do is ignore them because they change things… they push the human race forward, and while some may see them as the crazy ones, we see genius, because the ones who are crazy enough to think that they can change the world, are the ones who do.", "We are repeatedly what we do. Excellence, then, is not an act, but a habit.", "Stop wearing your wishbone where your backbone ought to be.", "Anything or anyone that does not bring you alive is too small for you.", "There will always be suffering. But we must not suffer over the suffering.", "I can give you my loneliness, my darkness, the hunger of my heart, I am trying to bribe you with uncertainty, with danger, with defeat.", "You must learn one thing. The world was made to be free in. Give up all the other worlds Except the one in which you belong.", "If anything is worth doing, it is worth doing it badly.", "Owning our story can be hard but not nearly as difficult as spending our lives running from it. Embracing our vulnerabilities is risky but not nearly as dangerous as giving up on love and belonging and joy—the experiences that make us the most vulnerable. Only when we are brave enough to explore the darkness will we discover the infinite power of our light.", "Your life is not a problem to be solved but a gift to be opened.", "Forget safety. Live where you fear to live. Destroy your reputation. Be notorious.", "Think you\'re escaping and run into yourself. Longest way round is the shortest way home.", "No need to hurry. No need to sparkle. No need to be anybody but oneself.", "The world needs dreamers and the world needs doers But above all the world needs dreamers who do.", "Nothing, Everything, Anything, Something: If you have nothing, then you have everything, because you have the freedom to do anything, without the fear of losing something.", "The world breaks everyone and afterward many are strong at the broken places.", "The man who moves a mountain begins by carrying away small stones.", "The one who asks questions doesn\'t lose his way.", "Love everyone. Trust few. Paddle your own canoe.", "There\'s always a little truth behind every \"just kidding\". A little knowledge behind every \"I don\'t know\". A little emotion behind every \"I don\'t care\". And a little pain behind every \"it\'s okay\".", "Ready, aim, fire? Fire. Fire. Fire.", "If consensus is overrated, I think balance is, too. I have no interest in living a balanced life. I want a life of adventure.", "Enough of these phrases, conceit and metaphors, I want burning, burning, burning.", "I thank god for this most amazing day: for leaping greenly spirits of tress and a blue true dream of sky; for everything which is natural which is infinite which is yes.", "If you want to reach the sky, you better learn how to kneel.", "Remarkable is a choice.", "To be great, be whole; Exclude nothing, exaggerate nothing that is not you. Be whole in everything. Put all you are Into the smallest thing you do. The whole moon gleams in every pool.", "Loneliness is the human condition. Cultivate it. The way it tunnels into you allows your soul room to grow. Never expect to outgrow loneliness. Never hope to find people who will understand you, someone to fill that space. And intelligent, sensitive person is the exception, the very great exception. If you expect to find people who will understand you, you will grow murderous with disappointment. The best you\'ll ever do is to understand yourself, know what it is that you want, and not let the cattle stand in your way.", "Some feelings sink so deep into the heart that only loneliness can help you find them again. Some truths are so painful that only shame can help you live with them. Some things are so sad that only your soul can do the crying for them.", "Holy is the supernatural extra brilliant intelligent kindness of the soul.", "If I can stop one heart from breaking, I shall not live in vain.", "To see a World in a Grain of Sand And a Heaven in a Wild Flower, Hold Infinity in the palm of your hand And Eternity in an hour.", "If your daily life seems poor, do not blame it; blame yourself, tell yourself that you are not poet enough to call it forth its riches.", "I turned silences and nights into words. What was unutterable, I wrote down. I made the whirling world stand still.", "Our ability to grow is directly proportional to an ability to entertain the uncomfortable.", "I believe that everything happens for a reason. People change so that you can learn to let go, things go wrong so that you appreciate them when they\'re right, you believe lies so you eventually learn to trust no one but yourself, and sometimes good things fall apart so better things can fall together.", "The only way to stay sane is to go a little crazy.", "I went to the woods because I wished to live deliberately, to front only the essential facts of life, and see if I could not learn what it had to teach, and not, when I came to die, discover that I had not lived.", "Sometimes it\'s a little better to travel than to arrive.", "You may not be her first, her last, or her only. She loved before she may love again. But if she loves you now, what else matters? She\'s not perfect – you aren\'t either, and the two of you may never be perfect together but if she can make you laugh, cause you to think twice, and admit to being human and making mistakes, hold onto her and give her the most you can. She may not be thinking about you every second of the day, but she will give you a part of her that she knows you can break – her heart. So don\'t hurt her, don\'t change her, don\'t analyze and don\'t expect more than she can give. Smile when she makes you happy, let her know when she makes you mad, and miss her when she\'s not there.", "To love at all is to be vulnerable. Love anything and your heart will be wrung and possibly broken. If you want to make sure of keeping it intact you must give it to no one, not even an animal. Wrap it carefully round with hobbies and little luxuries; avoid all entanglements. Lock it up safe in the casket or coffin of your selfishness. But in that casket, safe, dark, motionless, airless, it will change. It will not be broken; it will become unbreakable, impenetrable, irredeemable. To love is to be vulnerable.", "Do not let your fire go out, spark by irreplaceable spark in the hopeless swamps of the not-quite, the not-yet, and the not-at-all. Do not let the hero in your soul perish in lonely frustration for the life you deserved and have never been able to reach. The world you desire can be won. It exists.. it is real.. it is possible.. it\'s yours.", "Peace comes from within.  Do not seek it without.", "Love is what we are born with. Fear is what we learn. The spiritual journey is the unlearning of fear and prejudices and the acceptance of love back in our hearts. Love is the essential reality and our purpose on earth. To be consciously aware of it, to experience love in ourselves and others, is the meaning of life. Meaning does not lie in things. Meaning lies in us.", "Another year is fast approaching. Go be that starving artist you\'re afraid to be. Open up that journal and get poetic finally. Volunteer. Suck it up and travel. You were not born here to work and pay taxes. You were put here to be part of a vast organism to explore and create. Stop putting it off. The world has much more to offer than what\'s on 15 televisions at TGI Fridays. Take pictures. Scare people. Shake up the scene. Be the change you want to see in the world.", "The really important kind of freedom involves attention, and awareness, and discipline, and effort, and being able truly to care about other people and to sacrifice for them, over and over, in myriad petty little unsexy ways, every day.", "Rock bottom became the solid foundation on which I rebuilt my life.");
my ($SERVICE_OK, $FLAG_GET_ERROR, $SERVICE_CORRUPT,
        $SERVICE_FAIL, $INTERNAL_ERROR) = (101, 102, 103, 104, 110);

my %MODES = (check => \&check, get => \&get, put => \&put);

my ($mode, $ip) = splice @ARGV, 0, 2;

unless (defined $mode and defined $ip) {
        warn "Invalid input data. Empty mode or ip address.";
        exit $INTERNAL_ERROR;
}

unless ($mode ~~ %MODES and $ip =~ /(\d{1,3}\.){3}\d{1,3}/) {
        warn "Invalid input data. Corrupt mode or ip address.";
        exit $INTERNAL_ERROR;
}

my $url = Mojo::URL->new();
$url->scheme('http');
$url->host($ip);
$url->port(80);

my $check_error = sub {
        my $tx  = shift;
	unless ($tx->success)  
	{
   		my ($err, $code) = $tx->error;
    		warn $code ? "$code response: $err" : "Connection error: $err";
    		print $code ? "$code" : "Connection error: $err";
                exit $SERVICE_FAIL;
	}
};

my $login = sub {
        my ($ua, $um, $up, $utype) = @_;
        $url->path('/index.php');
	$url->query(action=>'login');
        warn "Try login '$utype' '$um' with password '$up'";    
	my $tx;
	my $check_str;
	if($utype eq 'company')
	{
		$tx = $ua->post($url, form => {type => $utype, email => $um, passwd => $up});
       		$check_str = '<legend>Welcome <a href="index.php?action=info_'.$utype.'">'.$um.'</a>!</legend>';
	}
	else
	{
		$tx = $ua->post($url, form => {email => $um, passwd => $up});
		$check_str = '<legend>Welcome <a href="index.php?action=info_'.$utype.'">'.$um.'</a>!</legend>';
	}

	$check_error->($tx);
	my $res = $tx -> res;
        my $code = $res -> code;
	unless($code == 200)
	{
	        print 'Login fail';
                exit $SERVICE_CORRUPT;
	} 
	$url->query(Mojo::Parameters->new);
	$tx = $ua->get($url);
	$check_error -> ($tx);
	$res = $tx -> res;
	$code = $res -> code;
	my $content = $res -> content;
        unless((defined $code) and ($code == 200) and ($content->body_contains($check_str)))
	{
                print 'Login fail';
                exit $SERVICE_CORRUPT;
        }
        warn 'Login successful';
};

my $register = sub {
	my ($uagent, %up) = @_; 
	
	$url->path('/index.php');
	$url->query(action=>'registration');
        warn "Try register user '$up{'mail'}' with password '$up{'pass'}'";
       
	my $tx = $uagent->post($url, form => { passwd => $up{'pass'}, repassword => $up{'pass'}, email => $up{'mail'}, type_table => $up{'type'}});
        $check_error -> ($tx);
	my $res = $tx -> res;
	my $code = $res-> code;
	my $content = $res -> content;
	my $check_str_0 = '<legend>Welcome <a href="index.php?action=info_'.$up{'type'}.'">'.$up{'mail'}.'</a>!</legend>';
	unless ((defined $code) and ($code == 200) and $content->body_contains($check_str_0)) 
	{
                print 'Registration fail';
                warn 'Registration first step fail';
                exit $SERVICE_CORRUPT;
        }

	my $check_str = '<div class="well carousel slide span10" id="myCarousel">';	
	
	if($up{'type'} eq 'user')
	{    	
		$url->query(action=>'reg_user');
        	warn "Continue register '$up{'type'}' '$up{'mail'}' with password '$up{'pass'}' and flag '$up{'max_sum'}'";
		$tx = $uagent -> post($url, form => {name => $up{'name'}, surname => $up{'surname'}, country => $up{'country'}, birthday => $up{'birthday'}, numbers => $up{'phone'}, max_sum => $up{'max_sum'}, currency => $up{'currency'}, doc => { filename => $up{'filename'}, content => 'SimpleText' } });
		$res = $tx -> res;
	}
	if($up{'type'} eq 'company')
	{
		$url->query(action=>'reg_company');
	        warn "Continue register '$up{'type'}' '$up{'name'}' with password '$up{'pass'}' and flag '$up{'max_sum'}'";
		$tx = $uagent -> post($url, form => {name_company => $up{'name'}, country => $up{'country'}, address => $up{'addr'}, created => $up{'date'}, numbers => $up{'phone'}, owner => $up{'owner'}, max_sum => $up{'max_sum'}, currency => $up{'currency'}, doc => {filename => $up{'filename'}, content => 'SimpleText'}});
	}
	$res = $tx -> res;
        $code = $res -> code;
	$content = $res -> content;
	unless((defined $code) and ($code == 200) and ($content->body_contains($check_str))  and ($content->body_contains($check_str_0)))
	{
		print 'Registration fail';
                warn 'Registration second step fail';
		warn $check_str;
                exit $SERVICE_CORRUPT;
	} 
	warn 'Registration successful';
}; 

my $create_card = sub
{
	my ($ua, $um, $usum,$utype) = @_;
        $url->path('/index.php');
        $url->query(action=>'addacct');
        warn "Try add card for '$utype' '$um' with sum '$usum'";
        my $tx = $ua->post($url, form => {summ => $usum, type => $utype});
        $check_error->($tx);
	my $res = $tx -> res;
        my $code = $res -> code;
        unless($code == 200)
        {
                print 'Add new card fail';
                exit $SERVICE_CORRUPT;
        }
	warn 'Add card successful';
};

my $add_comment = sub
{
	my ($ua, $um, $utext) = @_;
	$url->query(action=>'add_review');
	warn "Try add comment for user '$um' with text: '$utext'";
	my $tx = $ua->post($url, form => {comment => $utext, submit => ''});
	$check_error->($tx);
	my $res = $tx -> res;
	my $code = $res -> code;
	unless($code == 200)
        {
                print 'Add comment fail';
                exit $SERVICE_CORRUPT;
        }
        warn 'Add comment successful';
};

my $transfer = sub
{
	my ($ua, $from, $to) = @_;
	$url->query(action=>'transfer');
	warn "Try transfer from '$from' to '$to'";
	my $tx = $ua -> post($url, from => {acct_out => $from, acct_in => $to, sum => '10'});
	$check_error -> ($tx);
	my $res = $tx -> res;
	my $code = $res -> code;
	unless($code == 200)
	{
                print 'Transfer fail';
                exit $SERVICE_CORRUPT;
	}
	warn 'Transfer successful';
};

my $check_doc_name = sub
{
	my ($ua, $docname, $acc_type) = @_;
	$url -> query(action => 'info_'.$acc_type);
	warn "Check filename";
	my $tx = $ua -> get($url);
	$check_error -> ($tx);
	my $res = $tx -> res;
	my $code = $res -> code;
	my $content = $res -> content -> get_body_chunk(0);
	$content =~ /<p>Doc:\s+(.*)<\/p>/;
	unless($code == 200 and $docname eq $1)
	{
		warn "Check filename doc fail. Expect: $docname, but received $1.";
		exit $SERVICE_CORRUPT;
	} 
	warn 'Check filename successful';
};

my $check_max_sum = sub
{
	my ($ua, $max_sum, $acc_type) = @_;
	$url -> query(action => 'acct_'.$acc_type);
	warn "Check max_sum";
	my $tx = $ua -> get($url);
	$check_error -> ($tx);
	my $res = $tx -> res;
	my $code = $res -> code;
	my $content = $res -> content -> get_body_chunk(0);
	$content =~ /<tbody>\s+<tr><td>\d+<\/td><td>100<\/td><td>(.+)<\/td><td>.<\/td><\/tr>/;
	unless($code == 200 and $max_sum eq $1.'=')
	{
		warn "Check max_sum fail. Expect: $max_sum, but received $1";
		exit $SERVICE_CORRUPT;
	}
	warn 'Check max_sum successfull';
};

$MODES{$mode}->(@ARGV);
exit $SERVICE_OK;

sub check 
{	
my ($id, $flag) = @_;
	warn "put $ip $id $flag";
        my $ua = Mojo::UserAgent->new();
	my $type_flag = int(rand(3));
	my $uphone = ''; for(0..9){$uphone .= int(rand(9)+1);}
	my ($upass, $ucountry, $ufilename) = (rname(30), $countries[int(rand(@countries+0))], rname().'.jpeg');
	my $ucurrency;
        if(int(rand(2)) == 0) {$ucurrency = '$'} else {$ucurrency = '€'}


	if($type_flag == 0) #user
	{
		chop $flag;
		my ($uname, $usurname, $ubirthday) = ($names[int(rand(@names+0))].'.'.$uphone, $surnames[int(rand(@surnames+0))], int(rand(40)+1950).'-'.int(rand(12)+1).'-'.int(rand(28)+1));
		my $umail = $usurname.$uname.'@'.rname().'.com';
		$register->($ua, name => $uname, surname => $usurname, pass => $upass, type => 'user', mail => $umail, country => $ucountry, phone => $uphone, birthday => $ubirthday, max_sum => $flag, currency => '=', filename => $ufilename);
		$add_comment -> ($ua, $umail, $quote[int(rand(@quote))]);
		warn "0:$umail:$upass";
	}
	if($type_flag == 1)#company
	{
		chop $flag;
		my ($uname, $uaddr, $udate, $uowner) = ($companies[int(rand(@companies+0))].'.'.$uphone.'.'.$animals[int(rand(@animals+0))], rname(), int(rand(40)+1950).'-'.int(rand(12)+1).'-'.int(rand(28)+1), $names[int(rand(@names+0))].' '.$surnames[int(rand(@surnames+0))]);
		my $umail = $uname.'@'.rname().'.com';
		$register->($ua, name => $uname, pass => $upass, mail => $umail, country => $ucountry, addr => $uaddr, date => $udate, owner => $uowner, phone => $uphone, type => 'company', max_sum => $flag, filename => $ufilename, currency => '=');
		warn "1:$umail:$upass";
	}	
	if($type_flag == 2)
	{
		if(int(rand(2)) == 0) #company
		{
		 	my ($uname, $uaddr, $udate, $uowner) = ($companies[int(rand(@companies+0))].'.'.$uphone.'.'.$animals[int(rand(@animals+0))], rname(), int(rand(40)+1950).'-'.int(rand(12)+1).'-'.int(rand(28)+1), $names[int(rand(@names+0))].' '.$surnames[int(rand(@surnames+0))]);
                	my $umail =  $uname.'@'.rname().'.com';
			$register->($ua, name => $uname, pass => $upass, mail => $umail, country => $ucountry, addr => $uaddr, date => $udate, owner => $uowner, phone => $uphone, type => 'company', max_sum => rname(), filename => $flag, currency => $ucurrency);
                	warn "21:$umail:$upass";
		}
		else #user
		{
			my ($uname, $usurname, $ubirthday, $ufilename) = ($names[int(rand(@names+0))].'.'.$uphone, $surnames[int(rand(@surnames+0))], int(rand(40)+1950).'-'.int(rand(12)+1).'-'.int(rand(28)+1));
        	         my $umail = $usurname.$uname.'@'.rname().'.com';
			$register->($ua, name => $uname, surname => $usurname, pass => $upass, type => 'user', mail => $umail, country => $ucountry, phone => $uphone, birthday => $ubirthday, max_sum => rname(), currency => $ucurrency, filename => $flag);
		       	warn "22:$umail:$upass";
		}
	}
}

sub put 
{
	my ($id, $flag) = @_;
	warn "put $ip $id $flag";
        my $ua = Mojo::UserAgent->new();
	my $type_flag = int(rand(3));
	my $uphone = ''; for(0..9){$uphone .= int(rand(9)+1);}
	my ($upass, $ucountry, $ufilename) = (rname(30), $countries[int(rand(@countries+0))], rname().'.jpeg');
	my $ucurrency;
        if(int(rand(2)) == 0) {$ucurrency = '$'} else {$ucurrency = '€'}


	if($type_flag == 0) #user
	{
		chop $flag;
		my ($uname, $usurname, $ubirthday) = ($names[int(rand(@names+0))].'.'.$uphone, $surnames[int(rand(@surnames+0))], int(rand(40)+1950).'-'.int(rand(12)+1).'-'.int(rand(28)+1));
		my $umail = $usurname.$uname.'@'.rname().'.com';
		$register->($ua, name => $uname, surname => $usurname, pass => $upass, type => 'user', mail => $umail, country => $ucountry, phone => $uphone, birthday => $ubirthday, max_sum => $flag, currency => '=', filename => $ufilename);
		$add_comment -> ($ua, $umail, $quote[int(rand(@quote))]);
		print "0:$umail:$upass";
	}
	if($type_flag == 1)#company
	{
		chop $flag;
		my ($uname, $uaddr, $udate, $uowner) = ($companies[int(rand(@companies+0))].'.'.$uphone.'.'.$animals[int(rand(@animals+0))], rname(), int(rand(40)+1950).'-'.int(rand(12)+1).'-'.int(rand(28)+1), $names[int(rand(@names+0))].' '.$surnames[int(rand(@surnames+0))]);
		my $umail = $uname.'@'.rname().'.com';
		$register->($ua, name => $uname, pass => $upass, mail => $umail, country => $ucountry, addr => $uaddr, date => $udate, owner => $uowner, phone => $uphone, type => 'company', max_sum => $flag, filename => $ufilename, currency => '=');
		print "1:$umail:$upass";
	}	
	if($type_flag == 2)
	{
		if(int(rand(2)) == 0) #company
		{
		 	my ($uname, $uaddr, $udate, $uowner) = ($companies[int(rand(@companies+0))].'.'.$uphone.'.'.$animals[int(rand(@animals+0))], rname(), int(rand(40)+1950).'-'.int(rand(12)+1).'-'.int(rand(28)+1), $names[int(rand(@names+0))].' '.$surnames[int(rand(@surnames+0))]);
                	my $umail =  $uname.'@'.rname().'.com';
			$register->($ua, name => $uname, pass => $upass, mail => $umail, country => $ucountry, addr => $uaddr, date => $udate, owner => $uowner, phone => $uphone, type => 'company', max_sum => rname(), filename => $flag, currency => $ucurrency);
                	print "21:$umail:$upass";
		}
		else #user
		{
			my ($uname, $usurname, $ubirthday, $ufilename) = ($names[int(rand(@names+0))].'.'.$uphone, $surnames[int(rand(@surnames+0))], int(rand(40)+1950).'-'.int(rand(12)+1).'-'.int(rand(28)+1));
        	         my $umail = $usurname.$uname.'@'.rname().'.com';
			$register->($ua, name => $uname, surname => $usurname, pass => $upass, type => 'user', mail => $umail, country => $ucountry, phone => $uphone, birthday => $ubirthday, max_sum => rname(), currency => $ucurrency, filename => $flag);
		       	print "22:$umail:$upass";
		}
	}
}

sub get
{
	my ($id, $flag) = @_;

        my $ua = Mojo::UserAgent->new();

        my @id = split ':', $id;
        my ($flag_type, $um, $up) = splice @id, 0, 3;

	warn "Get $ip for $um and $up. Type - $flag_type";

	if($flag_type == 0 )
	{
        	$login -> ($ua, $um, $up, 'user');
		$check_max_sum -> ($ua, $flag, 'user');
	}
	if($flag_type == 1 )
	{
		$login -> ($ua, $um, $up, 'company');
		$check_max_sum -> ($ua, $flag, 'company');
	}
	if($flag_type == 22)
	{
		$login -> ($ua, $um, $up, 'user');
		$check_doc_name -> ($ua, $flag, 'user');	
	}
	if($flag_type == 21)
	{
		$login -> ($ua, $um, $up, 'company');
		$check_doc_name -> ($ua, $flag, 'company');
	}
	
	
	
	exit $SERVICE_OK;
}

sub rname {
        my $count = shift || 12;
        my $name = '';

        $name .= chr 97 + int rand 26  for (1 .. $count);
        return $name;
}

