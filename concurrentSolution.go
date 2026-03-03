// Project CSI2120/CSI2520
// Winter 2026

// Completed by Roman Solomakha St. No. 300422752 and Daniela Bordeianu St. No. 300435411

package main

import (
	"fmt"
	"sync"
)

var unmatched = make(map[int]*Resident)
var mu sync.Mutex

func offer(rid int, rolIdx int, residents map[int]*Resident, programs map[string]*Program, wg *sync.WaitGroup) {
	defer wg.Done()

	r := residents[rid]
	if rolIdx >= len(r.rol) {
		mu.Lock()
		unmatched[r.residentID] = r
		mu.Unlock()
		return
	} else {
		evaluate(rid, rolIdx, r.rol[rolIdx], residents, programs, wg)
	}
}

func evaluate(rid int, rolIdx int, pid string, residents map[int]*Resident, programs map[string]*Program, wg *sync.WaitGroup) {
	p := programs[pid]
	r := residents[rid]
	mu.Lock()
	attempt := p.addResident(r)
	mu.Unlock()
	if attempt != nil { // took place of another resident
		wg.Add(1)
		go offer(attempt.residentID, 0, residents, programs, wg)
	}
	if r.matchedProgram != "" { // took free place
		return
	}
	//rejected
	wg.Add(1)
	go offer(rid, rolIdx+1, residents, programs, wg)
}

func main() {
	fmt.Println("ENTER the residents file and the programs file, separated by a space")
	fmt.Println("EXAMPLE: residents4000.csv programs4000.csv")
	fmt.Print("INPUT  : ")
	var r, p string
	fmt.Scanf("%s %s", &r, &p)
	fmt.Print("\n")

	//for synchronization
	var wg sync.WaitGroup

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
	for _, r := range residents {
		wg.Add(1)
		go offer(r.residentID, 0, residents, programs, &wg)
	}
	wg.Wait()
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
	fmt.Println("\nEND OF PROGRAM")
}
