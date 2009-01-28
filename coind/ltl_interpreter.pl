%% COINDUCTIVE PREDICATES:
%%   coverify/2
%% "BOTTOM" PREDICATES:
%%   normalize/2
%%   proposition/1
%%   holds/2
%%   state/1
%%   trans/2

check(_9052, _9053) :-
        check_(_9052, _9053, []).

:- ['ltl_normalize.pl'].
check_(_1426, _1458, _7369) :-
        normalize(_1458, _1553),
        once(verify_(_1426,_1458,_7369)).
proposition(_1863) :-
        atom(_1863).
:- tabled verify_/3.
verify_(_2213, _2233, _7587) :-
        proposition(_2233),
        holds(_2213, _2233).
verify_(_2523, not(_2555), _7658) :-
        proposition(_2555),
        \+holds(_2523,_2555).
verify_(_2894, and(_2926,_2946), _7731) :-
        verify_(_2894, _2926, _7731),
        verify_(_2894, _2946, _7731).
verify_(_3295, or(_3327,_3347), _7877) :-
        (   verify_(_3295, _3327, _7877)
        ;   verify_(_3295, _3347, _7877)
        ).
verify_(_3715, x(_3747), _8023) :-
        '\\+_'(trans(_3715,_3825), \+verify(_3825,_3747), _8023).
verify_(_4145, f(_4177), _8104) :-
        (   verify_(_4145, _4177, _8104)
        ;   verify_(_4145, x(f(_4177)), _8104)
        ).
verify_(_4587, g(_4619), _8250) :-
        coverify_(_4587, g(_4619), _8250).
verify_(_4888, u(_4920,_4940), _8355) :-
        (   verify_(_4888, _4940, _8355)
        ;   verify_(_4888, and(_4920,x(u(_4920,_4940))), _8355)
        ).
verify_(_5453, r(_5485,_5505), _8501) :-
        coverify_(_5453, r(_5485,_5505), _8501).
coverify_(_8595, _8597, _8663) :-
        member(coverify(_8595,_8597), _8663).
coverify_(_5985, g(_6017), _8732) :-
        _8778=[coverify(_5985,g(_6017))|_8732],
        verify_(_5985, and(_6017,x(g(_6017))), _8778).
coverify_(_6372, r(_6404,_6424), _8854) :-
        _8900=[coverify(_6372,r(_6404,_6424))|_8854],
        verify_(_6372, and(_6404,_6424), _8900).
coverify_(_6737, r(_6769,_6789), _8976) :-
        _9022=[coverify(_6737,r(_6769,_6789))|_8976],
        verify_(_6737, and(_6789,x(r(_6769,_6789))), _9022).
