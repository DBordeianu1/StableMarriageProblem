// Project CSI2120/CSI2520
// Winter 2026

// Completed by Roman Solomakha St. No. 300422752 and Daniela Bordeianu St. No. 300435411

package main

import "fmt"

var unmatched = make(map[int]*Resident)

func algorithm(r *Resident, programs map[string]*Program){
	for _, pID := range(r.rol){ // go through all programs on resident's rol
		p := programs[pID]
		attempt := p.addResident(r)
		if attempt != nil{ // took place of another resident
			algorithm(attempt, programs)// place the other resident
			return
		}
		if r.matchedProgram != ""{ // took free place
			return
		}
	}
	unmatched[r.residentID] = r // couldn't find a program for resident 
	return
}

func main() {
	fmt.Println("ENTER the residents file and the programs file, separated by a space")
	fmt.Println("EXAMPLE: residents4000.csv programs4000.csv")
	fmt.Print("INPUT  : ")
	var r, p string 
	fmt.Scanf("%s %s", &r, &p)
	fmt.Print("\n")
	residents, err := ReadResidentsCSV(r)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}

	for _, p := range residents {
		fmt.Printf("ID: %d, Name: %s %s, Rol: %v\n", p.residentID, p.firstname, p.lastname, p.rol)
	}
	
	programs, err := ReadProgramsCSV(p)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}

	for _, p := range programs {
		fmt.Printf("ID: %s, Name: %s, Number of pos: %d, Number of applicants: %d\n", p.programID, p.name, p.nPositions, len(p.rol))
	}
	fmt.Print("\n")
	for _, r := range residents{
		algorithm(r, programs)
	}
	fmt.Println("lastname,firstname,residentID,programID,name")
	for _, r := range residents{
		if r.matchedProgram != ""{
			fmt.Printf("%v,%v,%v,%v,%v\n", r.lastname, r.firstname, r.residentID, r.matchedProgram, programs[r.matchedProgram].name)
		}
	}
	fmt.Println()
	fmt.Println("Number of unmatched residents :", len(unmatched))
	totalAvalible := 0
	for _, p := range programs{
		totalAvalible += (cap(p.selectedResidents) - len(p.selectedResidents))
	}
	fmt.Println("Number of positions available :", totalAvalible)
	fmt.Println("\nEND OF PROGRAM")
}