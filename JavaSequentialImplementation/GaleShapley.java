// Project CSI2120/CSI2520
// Winter 2026
// Robert Laganiere, uottawa.ca

// Completed by Roman Solomakha St. No. 300422752 and Daniela Bordeianu St. No. 300435411
import java.io.*;
import java.util.HashMap;

// this is the (incomplete) class that will generate the resident and program maps
public class GaleShapley {
	
	public HashMap<Integer,Resident> residents;
	public HashMap<String,Program> programs;
	public HashMap<Integer,Resident> unmatched = new HashMap<Integer,Resident>();	// keep track of unmatched residents
	
	/**
	 * Constructs an object of type GaleShapley
	 * 
	 * @param residentsFilename the name of the list of the residents' input file
	 * @param programsFilename the name of the list of the programs' input file
	 * @throws IOException if readResidents(String) or readPrograms(String) throws an exception
	 * @throws NumberFormatException if readResidents(String) or readPrograms(String) throws an exception
	 */
	public GaleShapley(String residentsFilename, String programsFilename) throws IOException, 
													NumberFormatException {
		
		readResidents(residentsFilename);
		readPrograms(programsFilename);
	}
	
	/**
	 * Reads the residents csv file. It populates the residents HashMap
	 * 
	 * @param residentsFilename the name of the file containing the residents
	 * @throws IOException if the file has an invalid format
	 * @throws NumberFormatException if the file has an invalid format
	 */
    public void readResidents(String residentsFilename) throws IOException, 
													NumberFormatException {

        String line;
		residents= new HashMap<Integer,Resident>();
		BufferedReader br = new BufferedReader(new FileReader(residentsFilename)); 

		int residentID;
		String firstname;
		String lastname;
		String plist;
		String[] rol;

		// Read each line from the CSV file
		line = br.readLine(); // skipping first line
		while ((line = br.readLine()) != null && line.length() > 0) {

			int split;
			int i;

			// extracts the resident ID
			for (split=0; split < line.length(); split++) {
				if (line.charAt(split) == ',') {
					break;
				} 
			}
			if (split > line.length()-2)
				throw new IOException("Error: Invalid line format: " + line);

			residentID= Integer.parseInt(line.substring(0,split));
			split++;

			// extracts the resident firstname
			for (i= split ; i < line.length(); i++) {
				if (line.charAt(i) == ',') {
					break;
				} 
			}
			if (i > line.length()-2)
				throw new IOException("Error: Invalid line format: " + line);

			firstname= line.substring(split,i);
			split= i+1;
			
			// extracts the resident lastname
			for (i= split ; i < line.length(); i++) {
				if (line.charAt(i) == ',') {
					break;
				} 
			}
			if (i > line.length()-2)
				throw new IOException("Error: Invalid line format: " + line);

			lastname= line.substring(split,i);
			split= i+1;		
				
			Resident resident= new Resident(residentID,firstname,lastname);

			for (i= split ; i < line.length(); i++) {
				if (line.charAt(i) == '"') {
					break;
				} 
			}
			
			// extracts the program list
			plist= line.substring(i+2,line.length()-2);
			String delimiter = ","; // Assuming values are separated by commas
			rol = plist.split(delimiter);
			
			resident.setROL(rol);
			
			residents.put(residentID,resident);
		}	
    }

	/**
	 * Reads the programs csv file. It populates the programs HashMap
	 * 
	 * @param programsFilename the name of the file containing the programs
	 * @throws IOException if the file has an invalid format
	 * @throws NumberFormatException if the file has an invalid format
	 */
    public void readPrograms(String programsFilename) throws IOException, 
													NumberFormatException {

        String line;
		programs= new HashMap<String,Program>();
		BufferedReader br = new BufferedReader(new FileReader(programsFilename)); 

		String programID;
		String name;
		int quota;
		String rlist;
		int[] rol;

		// Read each line from the CSV file
		line = br.readLine(); // skipping first line
		while ((line = br.readLine()) != null && line.length() > 0) {

			int split;
			int i;

			// extracts the program ID
			for (split=0; split < line.length(); split++) {
				if (line.charAt(split) == ',') {
					break;
				} 
			}			
			if (split > line.length()-2)
				throw new IOException("Error: Invalid line format: " + line);


			programID= line.substring(0,split);
			split++;

			// extracts the program name
			for (i= split ; i < line.length(); i++) {
				if (line.charAt(i) == ',') {
					break;
				} 
			}
			if (i > line.length()-2)
				throw new IOException("Error: Invalid line format: " + line);
			
			name= line.substring(split,i);
			split= i+1;
			
			// extracts the program quota
			for (i= split ; i < line.length(); i++) {
				if (line.charAt(i) == ',') {
					break;
				} 
			}
			if (i > line.length()-2)
				throw new IOException("Error: Invalid line format: " + line);

			quota= Integer.parseInt(line.substring(split,i));
			split= i+1;		
				
			Program program= new Program(programID,name,quota);

			for (i= split ; i < line.length(); i++) {
				if (line.charAt(i) == '"') {
					break;
				} 
			}
			
			// extracts the resident list
			rlist= line.substring(i+2,line.length()-2);
			String delimiter = ","; // Assuming values are separated by commas
			String[] rol_string = rlist.split(delimiter);
			rol= new int[rol_string.length];
			for (int j=0; j<rol_string.length; j++) {
				
				rol[j]= Integer.parseInt(rol_string[j]);
			}
			
			program.setROL(rol);
			
			programs.put(programID,program);
		}	
    }

	/**
	 * Implementation of the Gale-Shapley algorithm
	 * 
	 * @param r the resident with which the Gale-Shapley algorthim is initiated
	 */
    public void algorithm(Resident r){
    	String[] rol = r.getROL();
    	for (int i = 0; i < rol.length; i++){	// go through all programs on resident's rol
    		Program p = programs.get(rol[i]);
    		Resident attempt = p.addResident(r);
    		if (attempt != null){	// took place of another resident
    			algorithm(attempt);	// place the other resident
    			return;
    		}
    		if (r.getRank() != -1){	// took free place
    			return;
    		}
    	}
    	unmatched.put(r.getID(), r);	// couldn't find a program for resident 
    	return;
    }

	/**
	 * The entry point of the program. Instanciates a GaleShapley instance
	 * Reads input arguments from the console. Calls methods that process the input files
	 * 
	 * @param args the arguments from the console
	 */
	public static void main(String[] args) {
		
		GaleShapley gs = null;
		try {
			
			gs = new GaleShapley(args[0],args[1]);
			
			System.out.println(gs.residents);
			System.out.println(gs.programs);
			System.out.println();
			
        } catch (Exception e) {
            System.err.println("Error reading the file: " + e.getMessage()); 
        }

        for (Resident r : gs.residents.values()){	// go through all the residents one by one
    		gs.algorithm(r);
    	}
    	System.out.println("lastname,firstname,residentID,programID,name");
    	for (Resident r : gs.residents.values()){
    		if (r.getRank() != -1){
    			System.out.println(r.getLastname()+","+r.getFirstname()+","+Integer.toString(r.getID())+","+r.getMatchedProgram().getID()+","+r.getMatchedProgram().getName());
    		}
    	}
    	System.out.println();
    	System.out.println("Number of unmatched residents : "+Integer.toString(gs.unmatched.size()));
    	int totalAvalible = 0;
    	for (Program p : gs.programs.values()){
    		totalAvalible += p.available();
    	}
    	System.out.println("Number of positions available : "+Integer.toString(totalAvalible));
	}
}
