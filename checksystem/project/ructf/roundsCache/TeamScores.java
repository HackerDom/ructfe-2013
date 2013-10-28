package ructf.roundsCache;

public class TeamScores {

	int privacy;
	int availability;
	int attack;
	int advisories;
	int tasks;
	
	
	public TeamScores(int privacy, int availability, int attack, int advisories, int tasks)
	{		
		this.privacy = privacy;
		this.availability = availability;
		this.attack = attack;
		this.advisories = advisories;
		this.tasks = tasks;
	}

	
	/**
	 * @return the privacy
	 */
	public int getPrivacy() {
		return privacy;
	}

	/**
	 * @return the availability
	 */
	public int getAvailability() {
		return availability;
	}

	/**
	 * @return the attack
	 */
	public int getAttack() {
		return attack;
	}

	/**
	 * @return the advisories
	 */
	public int getAdvisories() {
		return advisories;
	}

	/**
	 * @return the tasks
	 */
	public int getTasks() {
		return tasks;
	}

	public TeamScores Clone() {
		return new TeamScores(privacy, availability, attack, advisories, tasks);
	}


	public void Add(TeamScores teamScores) {
		privacy += teamScores.getPrivacy();
		availability += teamScores.getAvailability();
		attack += teamScores.getAttack();
		advisories += teamScores.getAdvisories();
		tasks += teamScores.getTasks();		
	}
	
}
