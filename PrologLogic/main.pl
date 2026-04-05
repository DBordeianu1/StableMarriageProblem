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

rankInProgramHelper(ResidentID,_,[ResidentID|_],Rank,Rank):- !.

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
    leastPreferredHelper(ProgramID,ResidentIDsList,none,0,LeastPreferredResidentID,RankofThisResident,Rol,1).

% Went through the whole list so return the current resident's data
leastPreferredHelper(_,_,CurrentID,CurrentRank,CurrentID,CurrentRank,[],_):- !.

% The resident is not in the rol, so skip it
leastPreferredHelper(ProgramID,ResidentIDsList,CurrentID,CurrentRank,LeastPreferredResidentID,RankofThisResident,[H|T],Pos):-
    \+ member(H,ResidentIDsList),
    NextPos is Pos+1,
    leastPreferredHelper(ProgramID,ResidentIDsList,CurrentID,CurrentRank,LeastPreferredResidentID,RankofThisResident,T,NextPos),!.

% Resident is in the rol, update if needed
leastPreferredHelper(ProgramID,ResidentIDsList,_,CurrentRank,LeastPreferredResidentID,RankofThisResident,[H|T],Pos):-
    member(H,ResidentIDsList),
    Pos>CurrentRank,!,
    NextPos is Pos+1,
    leastPreferredHelper(ProgramID,ResidentIDsList,H,Pos,LeastPreferredResidentID,RankofThisResident,T,NextPos).

% if Pos<=CurrentRank
leastPreferredHelper(ProgramID,ResidentIDsList,CurrentID,CurrentRank,LeastPreferredResidentID,RankofThisResident,[_|T],Pos):-
    NextPos is Pos+1,
    leastPreferredHelper(ProgramID,ResidentIDsList,CurrentID,CurrentRank,LeastPreferredResidentID,RankofThisResident,T,NextPos).

/*
matched verifies if a resident has already been matched to a program,
and if so, it returns its ID

?- matched(226,P,[match(nrs, [517]), match(obg, []), match(mmi,[126]),match(hep, [226,574])]).
P=hep.
*/
% matched(_,_,[]):-fail.

matched(ResidentID,ProgramID,[match(_,ResidentList)|T]):- \+ member(ResidentID,ResidentList),matched(ResidentID,ProgramID,T),!.

matched(ResidentID,ProgramID,[match(ProgramID,ResidentList)|_]):-member(ResidentID,ResidentList).

/*
offer tries to assign a program to a resident, it consists of the
interior loop of the GS algorithm

?- M = [match(nrs, []), match(obg, []), match(mmi, [126]),
match(hep, [226,574])], offer(517,M, NewM).
NewM = [match(nrs, [517]), match(obg, []),
match(mmi, [126]), match(hep, [226, 574])].
?- M = [match(nrs, [517]), match(obg, []), match(mmi, [126]),
match(hep, [226,574])], offer(403,M, NewM).
NewM = [match(nrs, [517]), match(obg, []),
match(mmi, [126]), match(hep, [403, 574])].
*/
offer(ResidentID,CurrentMatchSet,NewMatchSet):-
    resident(ResidentID,_,Rol),
    offerHelper(ResidentID,CurrentMatchSet,NewMatchSet,Rol).

offerHelper(_,CurrentMatchSet,CurrentMatchSet,[]):- !.

% If resident is not in the rol of program H
offerHelper(ResidentID,CurrentMatchSet,NewMatchSet,[H|T]):-
    program(H,_,_,ProgramRol),
     \+member(ResidentID,ProgramRol),
    offerHelper(ResidentID,CurrentMatchSet,NewMatchSet,T),!.

% Program has not reached its quota yet
offerHelper(ResidentID,CurrentMatchSet,NewMatchSet,[H|_]):-
    program(H,_,Quota,ProgramRol),
    member(ResidentID,ProgramRol),
    member(match(H,ResidentList),CurrentMatchSet),
    length(ResidentList,RListLength),
    Quota>RListLength,
    updateMatchSet(H,[ResidentID|ResidentList],CurrentMatchSet,NewMatchSet),!.

% Program is full and prefers r over r'
offerHelper(ResidentID,CurrentMatchSet,NewMatchSet,[H|_]):-
    program(H,_,Quota,ProgramRol),
    member(ResidentID,ProgramRol),
    member(match(H,ResidentList),CurrentMatchSet),
    length(ResidentList,RListLength),
    Quota=<RListLength,
    leastPreferred(H,ResidentList,LeastID,LeastRank),
    rankInProgram(ResidentID,H,Rank),
    LeastRank>Rank,
    delete(ResidentList,LeastID,TempList),
    updateMatchSet(H,[ResidentID|TempList],CurrentMatchSet,NewMatchSet),!.

% Program is full but does not prefer r
offerHelper(ResidentID,CurrentMatchSet,NewMatchSet,[_|T]):-
    offerHelper(ResidentID,CurrentMatchSet,NewMatchSet,T).

/*
updateMatchSet is used to append an element in the list
*/
updateMatchSet(H,NewEntry,[match(H,_)|Rest],[match(H,NewEntry)|Rest]):-!.
updateMatchSet(H,NewEntry,[H2|T],[H2|NewT]):-updateMatchSet(H,NewEntry,T,NewT).
