// Project CSI2120/CSI2520
// Winter 2026

// Completed by Roman Solomakha St. No. 300422752 and Daniela Bordeianu St. No. 300435411

package main

import (
	"fmt"
	"sync"
	"time"
)

var unmatched = make(map[int]*Resident)
var unmatchedMu sync.Mutex

func offer(r *Resident, programs map[string]*Program, wg *sync.WaitGroup) {
	defer wg.Done()
	pID := r.find()
	p := programs[pID]
	if pID == "" {
		unmatchedMu.Lock()
		unmatched[r.residentID] = r
		unmatchedMu.Unlock()
	} else {
		evaluate(r, p, programs, wg)
	}
}

func evaluate(r *Resident, p *Program, programs map[string]*Program, wg *sync.WaitGroup) {
	r.current += 1
	rank := p.rank(r.residentID)
	if rank == -1 { // chechking for member
		wg.Add(1)
		go offer(r, programs, wg)
		return
	} else {
		p.mu.Lock()
		if len(p.selectedResidents) < p.nPositions { // took free place
			p.selectedResidents = append(p.selectedResidents, r)
			r.matchedProgram = p.programID
			p.mu.Unlock()
			return
		} else { // took place of another resident
			lpos := p.leastPreferredPos()
			lres := p.selectedResidents[lpos]
			if rank < p.rank(lres.residentID) {
				p.selectedResidents[lpos] = r
				r.matchedProgram = p.programID
				lres.matchedProgram = ""
				p.mu.Unlock()
				wg.Add(1)
				go offer(lres, programs, wg)
				return
			}
		}
		p.mu.Unlock()
	}
	wg.Add(1)
	go offer(r, programs, wg)
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

	//for synchronization
	var wg sync.WaitGroup

	start := time.Now()
	for _, r := range residents {
		wg.Add(1)
		go offer(r, programs, &wg)
	}
	wg.Wait()
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
