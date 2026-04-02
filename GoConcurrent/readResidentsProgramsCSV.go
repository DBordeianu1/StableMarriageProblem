// Project CSI2120/CSI2520
// Winter 2026

// Completed by Roman Solomakha St. No. 300422752 and Daniela Bordeianu St. No. 300435411

package main

import (
	"encoding/csv"
	"fmt"
	"os"
	"strconv"
	"strings"
	"sync"
)

// The Resident data type
type Resident struct {
	residentID     int
	firstname      string
	lastname       string
	rol            []string // resident rank order list
	current        int
	matchedProgram string // will be "" for unmatched resident
}

// The Program data type
type Program struct {
	programID  string
	name       string
	nPositions int         // number of positions available (quota)
	rol        []int       // program rank order list
	rankMap    map[int]int // residentID rank position for O(1) lookup
	// TO ADD: a data structure for the selected resident IDs
	selectedResidents []*Resident // ADDED
	mu                sync.Mutex
}

// ADDED - Finds resident's next availible program
func (r Resident) find() string {
	if r.current == len(r.rol) {
		return ""
	}
	return r.rol[r.current]
}

// ADDED - Find resident's rank
func (p *Program) rank(resID int) int {
	pos, ok := p.rankMap[resID]
	if !ok {
		return -1 // returns -1 if resident not in program's ROL
	}
	return pos // returns resident's position in program's ROL, 0 being the most preferred
}

// ADDED - Find least preferred selected resident
func (p *Program) leastPreferredPos() int {
	worstRank := 0                          // higher rank = worse, starting worst rank = 0
	worstResident := -1                     // remembering worst resident
	for i, r := range p.selectedResidents { // checking every selected resident
		if p.rank(r.residentID) > worstRank { // only if the residents rank is worse than current worst
			worstRank = p.rank(r.residentID)
			worstResident = i
		}
	}
	return worstResident // returns position of worst ranked resident in selectedResidents
}

// Parse a resident's ROL
func parseRol(s string) []string {
	s = strings.TrimSpace(s)
	s = strings.TrimPrefix(s, "[")
	s = strings.TrimSuffix(s, "]")
	if s == "" {
		return []string{}
	}
	parts := strings.Split(s, ",")
	for i, part := range parts {
		parts[i] = strings.TrimSpace(part)
	}
	return parts
}

// Parse a program's ROL
func parseIntRol(s string) []int {
	s = strings.TrimSpace(s)
	s = strings.TrimPrefix(s, "[")
	s = strings.TrimSuffix(s, "]")
	if s == "" {
		return []int{}
	}
	parts := strings.Split(s, ",")
	var ints []int
	for _, part := range parts {
		pid, _ := strconv.Atoi(strings.TrimSpace(part))
		ints = append(ints, pid)
	}
	return ints
}

// ReadCSV reads a CSV file into a map of Resident
func ReadResidentsCSV(filename string) (map[int]*Resident, error) {

	// map to store residents by ID
	residents := make(map[int]*Resident)

	file, err := os.Open(filename)
	if err != nil {
		return nil, fmt.Errorf("unable to open file: %w", err)
	}
	defer file.Close()

	reader := csv.NewReader(file)

	// Read all records
	records, err := reader.ReadAll()
	if err != nil {
		return nil, fmt.Errorf("error reading CSV: %w", err)
	}

	// Skip header if present (assuming it is)
	for i, record := range records {
		if i == 0 && record[0] == "id" {
			continue
		}
		if len(record) < 4 {
			return nil, fmt.Errorf("invalid record at line %d: %v", i+1, record)
		}

		// Parse ID
		id, err := strconv.Atoi(record[0])
		if err != nil {
			return nil, fmt.Errorf("invalid ID at line %d: %w", i+1, err)
		}

		if _, exists := residents[id]; exists {
			fmt.Println(id)
		}

		residents[id] = &Resident{
			residentID:     id,
			firstname:      record[1],
			lastname:       record[2],
			rol:            parseRol(record[3]),
			current:        0,
			matchedProgram: "",
		}
	}

	return residents, nil
}

// reads a CSV file into a map of Program
func ReadProgramsCSV(filename string) (map[string]*Program, error) {

	// map to store programs by ID
	programs := make(map[string]*Program)

	file, err := os.Open(filename)
	if err != nil {
		return nil, fmt.Errorf("unable to open file: %w", err)
	}
	defer file.Close()

	reader := csv.NewReader(file)

	// Read all records
	records, err := reader.ReadAll()
	if err != nil {
		return nil, fmt.Errorf("error reading CSV: %w", err)
	}

	// Skip header if present (assuming it is)
	for i, record := range records {
		if i == 0 && record[0] == "id" {
			continue
		}
		if len(record) < 4 {
			return nil, fmt.Errorf("invalid record at line %d: %v", i+1, record)
		}

		// Parse number of positions
		np, err := strconv.Atoi(record[2])
		if err != nil {
			return nil, fmt.Errorf("invalid number at line %d: %w", i+1, err)
		}

		rol := parseIntRol(record[3])
		rm := make(map[int]int, len(rol))
		for i, id := range rol {
			rm[id] = i
		}
		programs[record[0]] = &Program{
			programID:         record[0],
			name:              record[1],
			nPositions:        np,
			rol:               rol,
			rankMap:           rm,
			selectedResidents: make([]*Resident, 0, np), // ADDED - initialises selectedResidents
		}

	}

	return programs, nil
}

// Example usage
/*
func main() {

    // read residents
	residents, err := ReadResidentsCSV("residents4000.csv")
	if err != nil {
		fmt.Println("Error:", err)
		return
	}

	for _, p := range residents {
		fmt.Printf("ID: %d, Name: %s %s, Rol: %v\n", p.residentID, p.firstname, p.lastname, p.rol)
	}

	programs, err := ReadProgramsCSV("programs4000.csv")
	if err != nil {
		fmt.Println("Error:", err)
		return
	}

	for _, p := range programs {
		fmt.Printf("ID: %s, Name: %s, Number of pos: %d, Number of applicants: %d\n", p.programID, p.name, p.nPositions, len(p.rol))
	}

    fmt.Printf("\nNMD: %v",programs["NMD"])
}
*/
