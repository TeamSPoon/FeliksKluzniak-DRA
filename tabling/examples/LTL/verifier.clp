%% Gopal Gupta's LTL interpreter (modified by F.K.).
%%
%% This is a version of verifier.tlp that has been extended to produce a
%% counterexample.
%%
%% Include with the definition of an automaton, which should specify
%% the following predicates:
%%      proposition/1   - succeeds only if the argument is a proposition,
%%                        can be used to enumerate all the symbols that denote
%%                        propositions.
%%      state/1         - succeeds only if the argument is a state,
%%                        can be used to enumerate all the symbols that denote
%%                        states.
%%      trans/2         - given the first argument (which should represent a
%%                        state S) nondeterministically produces the symbols
%%                        that represent all the states that can be reached from
%%                        S.
%%      holds/2         - succeeds only if the first argument represents a
%%                        state, and the second represents a proposition that
%%                        holds in that state.
%%
%% Invoke through
%%
%%    check( state, formula ).
%%
%% The formula will be normalized and negated by the program.


:- op( 10,  fy , ~   ).   % not
:- op( 20, xfy , ^   ).   % and
:- op( 30, xfy , v   ).   % or
:- op( 10,  fy , x   ).   % LTL: "next"
:- op( 10,  fy , f   ).   % LTL: "eventually"
:- op( 10,  fy , g   ).   % LTL: "always"
:- op( 20, xfx , u   ).   % LTL: "until"
:- op( 20, xfx , r   ).   % LTL: "release"

:- [ 'normalize.pl' ].


:- top check/2.     % make check( S, F ) available in its original form

% Don't transform these:

:- support holds/2, normalize/2, proposition/1, state/1, trans/2,
   automaton_error/0.



%% Check whether the state satisfies the formula.
%% This is done by checking that it does not satisfy the formula's negation.
%% (We have to apply the conditional, because our tabling interpreter does not
%%  support the cut, and we don't yet support negation for coinduction.)

check( State, Formula ) :-
        check_consistency,
        (
            state( State )
        ->
            true
        ;
            write( '\"' ),
            write( State ),
            write( '\" is not a state' ),
            nl,
            fail
        ),
        write( 'Query for state ' ),
        write( State ),
        write( ': ' ),
        write( Formula ),
        nl,
        once( normalize( ~ Formula, NormalizedNegationOfFormula ) ),
        write( '(Negated and normalized: ' ),
        write( NormalizedNegationOfFormula ),
        write( ')' ),
        nl,
        (
            once( verify( State, NormalizedNegationOfFormula, Path ) )
        ->
            write( 'COUNTEREXAMPLE: ' ),
%            once( append( Path, [], ClosedPath ) ),  % no good for infinite
%            write( ClosedPath ),
            write( Path ),
            nl,
            fail
        ;
            true
        ).


% Check the consistency of the automaton's description.
% NOTE: The dynamic declaration is necessary for Eclipse.
%       On Sicstus we will see a warning, but things will work fine otherwise.

:- dynamic automaton_error/0.

check_consistency :-
        retractall( automaton_error ),
        check_propositions,
        check_transitions,
        (
            automaton_error
        ->
            fail
        ;
            true
        ).


% Make sure propositions don't clash with operators.

check_propositions :-
        proposition( P ),
        (
            \+ atom( P )
        ->
            write( 'A proposition must be an atom: ' ),
            write( '\"' ),
            write( P ),
            write( '\"' ),
            nl,
            assert( automaton_error )
        ;
            true
        ),
        (
            member( P, [ 'v', 'x', 'f', 'g', 'u', 'r' ] )
        ->
            write( '\"v\", \"x\", \"f\", \"g\", \"u\" and \"r\" ' ),
            write( 'cannot be propositions: ' ),
            write( '\"' ),
            write( P ),
            write( '\"' ),
            nl,
            assert( automaton_error )
        ;
            true
        ),
        fail.

check_propositions.


% Make sure that there is no state with no outgoing transitions, and that all
% transitions are between states.

check_transitions :-
        trans( S1, S2 ),
        (
            (var( S1 ) ;  var( S2 ) ; \+ state( S1 ) ; \+ state( S2 ))
        ->
            write( 'Transitions can only occur between states: ' ),
            write( S1 ),
            write( ' ---> ' ),
            write( S2 ),
            nl,
            assert( automaton_error )
        ;
            true
        ),
        fail.

check_transitions :-
        state( S ),
        (
            (\+ trans( S, _Set ) ; trans( S, [] ))
        ->
            write( 'No transition out of state ' ),
            write( S ),
            nl,
            assert( automaton_error )
        ;
            true
        ),
        fail.

check_transitions.



%--- The formula is normalized: only propositions can be negated.

verify( S, g A,   Path ) :-  once( coverify( S, g A,   Path ) ).
verify( S, A r B, Path ) :-  once( coverify( S, A r B, Path ) ).
verify( S, A,     Path ) :-  A \= g _,  a \= _ r _,  tverify( S, A, Path ).


:- tabled tverify/3.

% NOTE:  The rule for conjunction imposes restrictions on paths,
%        so results might be different than for the version without paths.
%        The restriction is that the path for one conjunct must be a prefix
%        of the path for the other.

tverify( S, A,     [ S ]     ) :-  proposition( A ),    holds( S, A ).

tverify( S, ~ A,   [ S ]     ) :-  proposition( A ), \+ holds( S, A ).

tverify( S, A ^ B, Path      ) :-  verify( S, A, PathA ), verify( S, B, PathB ),
                                   (
                                       append( PathA, _, PathB )       % prefix?
                                   ->
                                       Path = PathB
                                   ;
                                       append( PathB, _, PathA )       % prefix?
                                   ->
                                       Path = PathA
                                   % otherwise fail!
                                   ).

tverify( S, A v B, Path      ) :-  verify( S, A, Path ) ; verify( S, B, Path ).

tverify( S, f A,   Path      ) :-  verify( S, A, Path )
                                   ;
                                   verify( S, x f A, Path ).

tverify( S, A u B, Path      ) :-  verify( S, B, Path )
                                   ;
                                   verify( S, A ^ x( A u B), Path ).

tverify( S, x A,   [ S | P ] ) :-  trans( S, S2 )  , verify( S2, A, P ).

                          % The last clause is correct only because the query is
                          % always negated, so for a successful query we will
                          % try out all the relevant clauses of trans/2 through
                          % backtracking.


:- coinductive coverify/3.

coverify( S, g A,   Path ) :-  verify( S, A ^ x g A,       Path ).

coverify( S, A r B, Path ) :-  verify( S, A ^ B,           Path ).

coverify( S, A r B, Path ) :-  verify( S, B ^ x( A r B ),  Path ).


% Disregard the path argument!
essence_hook( coverify( A, B, _ ), coverify( A, B ) ).
