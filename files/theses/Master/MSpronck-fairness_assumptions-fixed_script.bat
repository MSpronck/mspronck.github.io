::== Settings ==::
@echo off

::== Setup variables ==::
:: folder all files are in
set "folder=%cd%\" 
:: file to store the temporary formulae in
set "formulafile=strong_fairness_part.mcf" 
:: path to spec file from folder
set "specfile=Dekker\Dekker_spec.mcrl2"
:: path to lts file from folder
set "ltsfile=Dekker\Dekker_spec.lts"
:: path to lps file from folder
set "lpsfile=Dekker\Dekker_spec.lps"
:: file to store the temporary pbes in
set "pbesfile=Dekker_sfpart.pbes"
:: number of actions = N
set /a "numactions=18"
:: number of permutations that should be done, 2^numactions
set /a "permutations=262144"
:: number of processes
set /a "numprocesses=2"
:: set process number to start at
set /a "startprocess=0"
:: set permutation number to start at
set /a "startperm=0"
:: set whether to skip actions at x + process id
set "skipone=true"
:: set x in the above calculation
set /a "skipx=0"
:: choose whether to record results in a file
set "record=false"
:: set filename that results will be recorded in
set "resfile=starvation_freedom_sfa_results.txt"

::== Actual code ==::
set /a "sub=1"
set /a "perm = %permutations% - %sub%"
set /a "acts = %numactions% - %sub% - %sub%"
set /a "procs = %numprocesses% - %sub%"

SETLOCAL ENABLEDELAYEDEXPANSION
:: iterate through processes, start at startprocess in case the computation was interrupted.
for /l %%p in (%startprocess%,1,%procs%) do ( 
	:: iterate through permutations required, start at startperm in case computation was interrupted
	for /l %%n in (!startperm!,1,%perm%) do (
		:: initialise list for F
		set "list=["
		:: we need a bitmask comp to check whether each action is true in the list corresponding to this permutation
		set /a "comp=1"
		:: the variable skip tracks whether we should skip this list
		set "skip=false"
		:: iterate over the actions
		for /l %%i in (0,1,%acts%) do (
			:: test if, in the bit representation of n, the index of this action is 1
			set /a "res=%%n & !comp!"
			IF !res! GEQ 1 (
				:: if yes, add true to the list
				set "list=!list! true,"
				:: if we decide to skip, and we are looking at the action that needs to be skipped when true, then set skip to true
				IF !skipone! EQU true (
					set /a "calc = %skipx% + %%p"
					IF %%i EQU !calc! (
						set "skip=true"
					)
				)
			) ELSE (
				:: add false to the list if this action is not in this set
				set "list=!list! false,"
			)
			:: bitshift comp to test for the next action
			set /a "comp=!comp! << 1"
		)
		:: final action is handled separately to properly format list
		set /a "res=%%n & !comp!"
		IF !res! GEQ 1 (
			set "list=!list! true]"
			IF !skipone! EQU true (
				set /a "calc = %skipx% + %%p"
				IF %%i EQU !calc! (
					set "skip=true"
				)
			)
		) ELSE (
			set "list=!list! false]"
		)
		
		:: report information
		echo At p = %%p and n = %%n
		echo ^* Gives list: !list!

		IF !skip! EQU true (
			echo ^* Skipped
			:: if chosen to record information, add record to file
			IF !record! EQU true (
				echo At p = %%p and n = %%n >> "%folder%%resfile%"
				echo ^* List: !list! >> "%folder%%resfile%"
				echo ^* skipped >> "%folder%%resfile%"
			)
		) ELSE (
			:: set formula for this process and this F
			set "formula=^!(<true*.l(Noncrit( %%p ))>mu Y.(<^!l(Crit( %%p ))>Y || nu X.( mu W(num: Nat = 0).((val(num == N) => ((forall j:Nat.(val(j < N && ^!( !list!.j)) => [l(order(j))]false)) && X)) && (val(num < N && !list!.num) => ((forall j:Nat.(val(j < N && ^!( !list!.j)) => [l(order(j))]false)) && (<^!l(Crit( %%p ))>W(num) || <l(order(num)) && ^!l(Crit( %%p ))>W(num+1)))) && (val(num < N && ^!( !list!.num)) => (W(num+1)))))))"
		
			:: store formula temporarily
			echo !formula!>"%folder%%formulafile%"
		
			:: use powershell to call mcrl22lps, lps2lts and lts2pbes. I only know how to do this with powershell not batch directly, apologies
			powershell -C "mcrl22lps -q \"%folder%%specfile%\" \"%folder%%lpsfile%\""
            powershell -C "lps2lts -q \"%folder%%lpsfile%\" \"%folder%%ltsfile%\""
			powershell -C "lts2pbes -q -f \"%folder%%formulafile%\" \"%folder%%ltsfile%\" -l \"%folder%%lpsfile%\" \"%folder%%pbesfile%\""
		
			:: call pbessolve and save result
			FOR /F "tokens=* USEBACKQ" %%F IN (`powershell -C "pbessolve -s2 \"%folder%%pbesfile%\""`) DO (
				set var=%%F
			)
			
			:: report output
			echo ^* !var!
			:: if chosen to record information, add record to file
			IF !record! EQU true (
				echo At p = %%p and n = %%n >> "%folder%%resfile%"
				echo ^* List: !list! >> "%folder%%resfile%"
				echo ^* Result: !var! >> "%folder%%resfile%"
			)
			
			:: check if output was false
			IF !var! NEQ true (
				:: if so, we have a violating path, which we can report exists
				:: the violating path itself is not reported, this requires a more expensive calculation to find a counterexample
				echo Violating path found with p = %%p, n = %%n and list = !list!, property is false
		
				:: quit, we know the property is false
				goto :done
			)
		)
	)
	
	:: reset startperm, the next process should start at 0 again
	set /a "startperm = 0"
)

ENDLOCAL

:: if no violations are found, the property is true
echo No violating paths found, property is true

:done

:: keep on screen
PAUSE