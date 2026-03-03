// Project CSI2120/CSI2520
// Winter 2026

// Completed by Roman Solomakha St. No. 300422752 and Daniela Bordeianu St. No. 300435411

package main

import "fmt"
import "time"

var unmatched = make(map[int]*Resident)

func offer(r *Resident, programs map[string]*Program) {
	pID := r.find()
	p := programs[pID]
	if pID == ""{
		unmatched[r.residentID] = r
	} else {
		evaluate(r, p, programs)
	}
	return
}

func evaluate(r *Resident, p *Program, programs map[string]*Program){ // the * in *Program took me an hour to bugfix help
	r.current += 1
	rank := p.rank(r.residentID)
	if rank == -1 { // chechking for member
		offer(r, programs)
		return
	} else if len(p.selectedResidents) < p.nPositions{
		p.selectedResidents = append(p.selectedResidents, r) 
		r.matchedProgram = p.programID
		return
	} else {
		lpos := p.leastPreferredPos()
		lres := p.selectedResidents[lpos]
		if rank < p.rank(lres.residentID){
			p.selectedResidents[lpos] = r
			r.matchedProgram = p.programID
			lres.matchedProgram = ""
			offer(lres, programs)
			return
		}
	}
	offer(r, programs)
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

	/*for _, p := range residents {
		fmt.Printf("ID: %d, Name: %s %s, Rol: %v\n", p.residentID, p.firstname, p.lastname, p.rol)
	}*/

	programs, err := ReadProgramsCSV(p)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}

	/*for _, p := range programs {
		fmt.Printf("ID: %s, Name: %s, Number of pos: %d, Number of applicants: %d\n", p.programID, p.name, p.nPositions, len(p.rol))
	}*/
	fmt.Print("\n")
	start := time.Now()
	for _, r := range residents {
		offer(r, programs)
	}
	end := time.Now()
	fmt.Println("lastname,firstname,residentID,programID,name")
	for _, r := range residents {
		if r.matchedProgram != "" {
			fmt.Printf("%v,%v,%v,%v,%v\n", r.lastname, r.firstname, r.residentID, r.matchedProgram, programs[r.matchedProgram].name)
		}
	}
	fmt.Println()
	fmt.Println("Number of unmatched residents :", len(unmatched))
	totalAvalible := 0
	for _, p := range programs {
		totalAvalible += (cap(p.selectedResidents) - len(p.selectedResidents))
	}
	fmt.Println("Number of positions available :", totalAvalible)
	fmt.Printf("\nExecution time : %s", end.Sub(start))
	fmt.Println("\n\nEND OF PROGRAM")
}