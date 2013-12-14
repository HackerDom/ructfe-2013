#!/usr/bin/env python2

import random
import time
import md5
import re
import errno
import socket
import sys
import requests

PORT = 8000
TIMEOUT = 6

# exit codes
OK = 101
NOFLAG = 102
MUMBLE = 103
NOCONNECT = 104
INTERNALERROR = 110

names = [
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
    "Damaris"]

surnames = [
    "Smith", "Johnson", "Williams", "Jones", "Brown", "Davis", "Miller",
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
    "Knowles", "Cooke", "Velazquez", "Whitley", "Noel", "Vang"]

# only for countries with population > 10M
population_and_countrycode = [
    (10057975, 224), (10211904, 420), (10329208, 235), (10414336, 32), (10473282, 250),
    (10486339, 216), (10707924, 351), (10737428, 30), (11392629, 263), (11451652, 53),
    (11862740, 260), (12666987, 223), (12799293, 244), (13276517, 502), (13711597, 221),
    (14268711, 265), (14494293, 855), (14573101, 593), (15306252, 227), (15746232, 226),
    (16601707, 56), (16715999, 31), (18879301, 237), (20178485, 963), (20617068, 225),
    (20653556, 261), (21262641, 61), (21324791, 94), (21669278, 258), (22215421, 40),
    (22665345, 850), (22974347, 886), (23822783, 967), (23832495, 233), (25715819, 60),
    (26814843, 58), (27606007, 998), (28396000, 93), (28563377, 977), (28686633, 966),
    (28945657, 964), (29546963, 51), (32369558, 256), (34178188, 213), (34859364, 212),
    (38482919, 48), (39002772, 254), (40525002, 34), (40913584, 54), (41048532, 255),
    (41087825, 249), (45644023, 57), (45700395, 380), (48137741, 95), (48508972, 82),
    (49052489, 27), (58126212, 39), (61189717, 44), (64057792, 33), (65905410, 66),
    (66429284, 98), (68692542, 243), (76805524, 90), (82329758, 49), (83082869, 20),
    (85237338, 251), (86967524, 84), (97976603, 63), (111211789, 52), (127078679, 81),
    (149229090, 234), (155440684, 7), (156050883, 880), (176242949, 92), (198739269, 55),
    (240271522, 62), (344670351, 1), (1166079217, 91), (1338612968, 86)]

def gen_random_string(size=8):
    alph = list('abcdefghijklmnopqrstuvwxyz1234567890')
    return ''.join([random.choice(alph) for c in range(size)])

def gen_phone_number():
    # country probability is proportional to the population
    s = 0
    for population, code in population_and_countrycode:
        s += population

    chosenmannum = random.randrange(s)
    s = 0
    for population, code in population_and_countrycode:
        s += population
        if s >= chosenmannum:
            country_code = code
            break
    else:
        country_code = 3255  # should never happen

    # just random format
    return "+%d(%03d)%02d %02d %02d" % (country_code, random.randrange(1000), random.randrange(1000), random.randrange(1000), random.randrange(1000))

def wildcardify(s):
    "generates a wildcard mask for the string"
    ret = []
    can_insert_wildcard = True
    for pos, c in enumerate(s):
        place_wildcard = random.choice([True, False])
        if pos % 3 == 0:
            place_wildcard = True
        if place_wildcard:
            ret.append(c)
            can_insert_wildcard = True
        else:
            if can_insert_wildcard:
                ret.append("*")
                can_insert_wildcard = False
            else:
                continue
    return ''.join(ret)

def create_user(name, surname, email, password, phone):
    params = {
        "action": "add",
        "name" : name,
        "surname": surname,
        "phone": phone,
        "email": email,
        "password": password
    }

    resp = requests.get("http://%s:%s/" % (ip, PORT), params=params)

    if "Success" in resp.text:
        return "success"
    if "exists" in resp.text:
        return "exists"
    return "fail"

def check(ip):
    name = random.choice(names)
    surname = random.choice(surnames)
    email = gen_random_string()
    password = gen_random_string()
    phone = gen_phone_number()

    result = create_user(name, surname, email, password, phone)
    if result == "exists":
        name += gen_random_string()
        result = create_user(name, surname, email, password, phone)

    if result != "success":
        print("Unable to register a user")
        return MUMBLE

    query = wildcardify(name + " " + surname)

    params = {
        "action": "search",
        "q": query
    }

    resp = requests.get("http://%s:%s/" % (ip, PORT), params=params)

    if phone not in resp.text:
        print("Unable to search for the user")
        return MUMBLE

    params = {
        "action": "search",
        "raw": "True",
        "q": query
    }

    resp = requests.get("http://%s:%s/" % (ip, PORT), params=params)

    if ("telephoneNumber: %s" % phone) not in resp.text:
        print("Raw output in search is broken(test 0)")
        return MUMBLE
    if ("objectClass: inetOrgPerson") not in resp.text:
        print("Raw output in search is broken(test 1)")
        return MUMBLE
    if ("sn: %s" % surname) not in resp.text:
        print("Raw output in search is broken(test 2)")
        return MUMBLE

    return OK

def put(ip, flag_id, flag):
    name = random.choice(names)
    surname = random.choice(surnames)

    if random.choice([True, False]):
        email=flag
        password=gen_random_string()
    else:
        email=gen_random_string()
        password=flag

    phone = gen_phone_number()

    result = create_user(name, surname, email, password, phone)
    if result == "exists":
        name += gen_random_string()
        result = create_user(name, surname, email, password, phone)

    if result != "success":
        print("Unable to register a user")
        return MUMBLE

    print("%s_%s_%s" % (name, surname, password))

    return OK


def get(ip, flag_id, flag):
    try:
        name, surname, password = flag_id.split("_")
    except ValueError:
        print("Wrong flag id")
        return MUMBLE

    params = {
        "action": "info",
        "name": name,
        "surname": surname,
        "password": password
    }

    resp = requests.get("http://%s:%s/" % (ip, PORT), params=params)

    if flag not in resp.text and flag.encode("base64").replace("\n", "") not in resp.text:
        return NOFLAG

    print("ALL OK")

    return OK


### START ###
try:
    mode = sys.argv[1]

    if mode not in ('check', 'put', 'get'):
        sys.exit(INTERNALERROR)

    ret = INTERNALERROR
    if mode == 'check':
        ip = sys.argv[2]
        ret = check(ip)
    elif mode == 'put':
        ip, flag_id, flag = sys.argv[2:5]
        ret = put(ip, flag_id, flag)
    elif mode == 'get':
        ip, flag_id, flag = sys.argv[2:5]
        ret = get(ip, flag_id, flag)
    sys.exit(ret)
except socket.error as E:
    if E.errno == errno.ECONNRESET:
        sys.stderr.write( "connection reset by peer\n" )
        sys.exit(MUMBLE)
    else:
        sys.exit(NOCONNECT)
except requests.exceptions.ConnectionError as E:
        sys.stderr.write( "connection refused\n" )
        sys.exit(NOCONNECT)
except ValueError as E:
    print("WRONG ARGS")
    sys.exit(INTERNALERROR)
except IndexError as E:
    print("WRONG ARGS")
    sys.exit(INTERNALERROR)
except Exception as E:
    print(type(E))
    sys.stderr.write( str(E) )
    sys.exit(MUMBLE)
