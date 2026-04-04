/*
rankInProgram finds the rank of a resident

?- rankInProgram(403,nrs,R).
R = 3 .
?- rankInProgram(403,mmi,R).
false.
*/
rankInProgram(ResidentID,ProgramID,Rank):-
    program(ProgramID,_,_,Rol),
    rankInProgramHelper(ResidentID,ProgramID,Rol,1,Rank).

rankInProgramHelper(ResidentID,_,[ResidentID|_],Rank,Rank).

rankInProgramHelper(ResidentID,ProgramID,[H|T],Rank,RankTotal):-
    H\=ResidentID,
    RankTemp is Rank+1,
    rankInProgramHelper(ResidentID,ProgramID,T,RankTemp,RankTotal).

/*
leastPreferred finds the least preferred resident in a given program's
Rol

?- leastPreferred(nrs,[403, 517, 226, 828],Rid,Rank).
Rid = 226,
Rank = 5
*/
leastPreferred(ProgramID,ResidentIDsList,LeastPreferredResidentID,RankofThisResident):-
    program(ProgramID,_,_,Rol),
    leastPreferredHelper(ProgramID,ResidentIDsList,none,0,LeastPreferredResidentID,RankofThisResident,Rol).

% Went through the whole list so return the current resident's data
leastPreferredHelper(_,_,CurrentID,CurrentRank,CurrentID,CurrentRank,[]).

% The resident is not in the rol, so skip it
leastPreferredHelper(ProgramID,ResidentIDsList,CurrentID,CurrentRank,LeastPreferredResidentID,RankofThisResident,[H|T]):- \+ member(H,ResidentIDsList),
    leastPreferredHelper(ProgramID,ResidentIDsList,CurrentID,CurrentRank,LeastPreferredResidentID,RankofThisResident,T).

% Resident is in the rol, update if needed
leastPreferredHelper(ProgramID,ResidentIDsList,_,CurrentRank,LeastPreferredResidentID,RankofThisResident,[H|T]):-
    member(H,ResidentIDsList),
    rankInProgram(H,ProgramID,HRank),
    HRank>CurrentRank,
    leastPreferredHelper(ProgramID,ResidentIDsList,H,HRank,LeastPreferredResidentID,RankofThisResident,T).
