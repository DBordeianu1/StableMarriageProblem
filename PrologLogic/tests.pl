test(1):-rankInProgram(403,nrs,R), write(R).
test(2):-leastPreferred(nrs,[403, 517, 226, 828],Rid,Rank),write(Rid),write(' '),write(Rank).
test(3):-Ms = [match(nrs, [517]), match(obg, []), match(mmi, [126]),match(hep, [226,574])], matched(226,P,Ms),write(P).
test(4):-M=[match(nrs, []), match(obg, []), match(mmi, [126]),match(hep, [226,574])], offer(517,M, NewM),write(NewM).
test(5):-M = [match(nrs, [517]), match(obg, []), match(mmi, [126]),match(hep, [226,574])], offer(403,M, NewM),write(NewM).