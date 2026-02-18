// Project CSI2120/CSI2520
// Winter 2026
// Robert Laganiere, uottawa.ca

// this is the (incomplete) Resident class

// Completed by Roman Solomakha St. No. 300422752 and Daniela Bordeianu St. No. 300435411
public class Resident {
	
	private int residentID;
	private String firstname;
	private String lastname;
	private String[] rol;
	private Program matchedProgram; // null if the resident has not been matched
	private int matchedRank; // -1 if the resident has not been matched 
	
	/**
	 * Constructs a resident
	 * 
	 * @param id the identification for this resident
	 * @param fname the first name of the resident
	 * @param lname the last name of the resident
	 */
    public Resident(int id, String fname, String lname) {
		residentID = id;
		firstname = fname;
		lastname = lname;
		matchedProgram = null;
		matchedRank = -1;
	}

	/**
	 * Returns the resident's first name
	 * 
	 * @return the first name of the resident
	 */
	public String getFirstname(){
		return firstname;
	}

	/**
	 * Returns the resident's last name
	 * 
	 * @return the last name of the resident
	 */
	public String getLastname(){
		return lastname;
	}

	/**
	 * Returns the resident's id
	 * 
	 * @return the id of the resident
	 */
	public int getID(){
		return residentID;
	}

	/**
	 * Returns the resident's rank in the rol
	 * 
	 * @return the rank of the resident in the program's rol, can be -1 if not matched (yet)
	 */
	public int getRank(){
		return matchedRank;
	}

	/**
	 * Returns the resident's matched program
	 * 
	 * @return a reference to the matched program of the resident
	 */
	public Program getMatchedProgram(){
		return matchedProgram;
	}

	/**
	 * Returns the rol of the resident
	 * 
	 * @return a String array of the programs that are in the resident's rol
	 */
	public String[] getROL() {
		return rol;
	}

	/**
	 * Sets the rol of the resident in order of preference
	 * 
	 * @param rol the rol in order of preference
	 */
	public void setROL(String[] rol) {
		this.rol= rol;
	}

	/**
	 * Sets the program to which the resident has been matched to
	 * 
	 * @param program the resident's matched program
	 */
	public void setMatchedProgram(Program program){
		matchedProgram = program;
	}

	/**
	 * Sets the rank of the resident when matched to a program
	 * 
	 * @param i the rank of the resident
	 */
	public void setMatchedRank(int i){
		matchedRank = i;
	}
	
	/**
	 * Returns the string representation of the resident
	 * 
	 * @return the string representation of the resident
	 */
	public String toString() {
		return "["+residentID+"]: "+firstname+" "+ lastname+" ("+rol.length+")";	  
	}
}