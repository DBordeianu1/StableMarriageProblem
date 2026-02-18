// Project CSI2120/CSI2520
// Winter 2026
// Robert Laganiere, uottawa.ca

// this is the (incomplete) Program class

// Completed by Roman Solomakha St. No. 300422752 and Daniela Bordeianu St. No. 300435411
public class Program {
	
	private String programID;
	private String name;
	private int quota;
	private int[] rol; // important that it is in ascending order
	private Resident[] matchedResidents;
	private int pointer; // points at the first null cell in matchedResidents, cannot be greater than quota
	
	/**
	 * Constructs a Program
	 * 
	 * @param id the 3 letter identification for this program
	 * @param n the name of the program
	 * @param q the quota of the program, i.e. the available positions for it
	 */
    public Program(String id, String n, int q) {
		programID = id;
		name = n;
		quota = q;
		matchedResidents = new Resident[q];
		pointer = 0;
	}

	/**
	 * Sets the rol of the program in order of preference
	 * 
	 * @param rol the rol in order of preference
	 */
	public void setROL(int[] rol) {
		this.rol= rol;
	}
	
	/**
	 * Returns the string representation of the program
	 * 
	 * @return the string representation of the program
	 */
	public String toString() {
		return "["+programID+"]: "+name+" {"+ quota+ "}" +" ("+rol.length+")";	  
	}

	/**
	 * Returns the number of available positions left
	 * 
	 * @return number of available positions left
	 */
	public int available(){
		return (quota - pointer);
	}

	/**
	 * Returns the 3 letter identification of a program
	 * 
	 * @return the 3 letter identification for this program
	 */
	public String getID(){
		return programID;
	}

	/**
	 * Returns the name of the program
	 * 
	 * @return the name of the program
	 */
	public String getName(){
		return name;
	}


	/**
	 * Returns true if the resident is a part of the rol of the program, false otherwise
	 * 
	 * @param residentID the identification of a resident
	 * @return {@code true} if the resident is a part of the program rol, {@code false} otherwise
	 */
	public boolean member(int residentID){
		for (int i=0;i<rol.length;i++){
			if (rol[i] == residentID){
				return true;
			}
		}
		return false;
	}


	/**
	 * Returns the rank of the resident, -1 if it is not present in the program's rol
	 * 
	 * @param residentID the identification of a resident
	 * @return the resident's rank from the rol of the program
	 */
	public int rank(int residentID){
		for (int i=0;i<rol.length;i++){
			if (rol[i] == residentID){
				return i+1; //0 cannot be a rank
			}
		}
		return -1; //if resident not in the list
	}

	/**
	 * Returns a referencce of the program's least preferred resident
	 * 
	 * @return a reference of the least preferred resident in the list of matched residents
	 */
	public Resident leastPreferred(){
		int worstRank = 0; // higher rank = worse, starting worst rank = 0
		int worstResident = -1; // remembering worst resident
		for (int i = (pointer - 1); i <= 0; i--){ // checking every matched resident 
			if (matchedResidents[i].getRank() > worstRank){ // only if the residents rank is worse than current worst
				worstRank = matchedResidents[i].getRank();
				worstResident = i;
			}
		}
		return matchedResidents[worstResident];
	}

	/**
	 * Returns the position of the program's least preferred resident
	 * 
	 * @return the position of the least preferred resident in the list of matched residents
	 */
	public int leastPreferredPos(){ 
		int worstRank = 0; 
		int worstResident = -1; 
		for (int i = (pointer - 1); i >= 0; i--){ 
			if (matchedResidents[i].getRank() > worstRank){ 
				worstRank = matchedResidents[i].getRank();
				worstResident = i;
			}
		}
		return worstResident;
	}

	/**
	 * Returns the newly matched resident
	 * 
	 * @param resident a reference to the resident
	 * @return a reference the resident added to the matched residents' list
	 */
	public Resident addResident(Resident resident){
		int r = rank(resident.getID());
		if (r != -1){ // chechking for member
			if (pointer != quota){ 	// if has not reached quota
				matchedResidents[pointer] = resident;
				resident.setMatchedProgram(this);
				resident.setMatchedRank(rank(resident.getID()));
				pointer++;
				return null;	// took free place
			}
			else {	// if has reached quota
				int l =  leastPreferredPos();
				Resident least = matchedResidents[l];
				if (r < least.getRank()) {
					matchedResidents[l] = resident;
					resident.setMatchedProgram(this);
					resident.setMatchedRank(r);
					least.setMatchedProgram(null);
					least.setMatchedRank(-1);
					return least;	// took place of another resident, return that resident
				}
			}
		}
		return null;	// isnt on the rol of this program, didn't get matched
	}
}