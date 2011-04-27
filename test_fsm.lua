--[[ 
File: test_fsm.lua

Description: Tests for the finite state machine library

Author: Erik Cornelisse
Version 1.0  April 27, 2011

]]--

require "luaunit"
FSM = require "fsm"

function action1() return 1 end	-- #1 Performaing action 1
function action2() return 2 end	-- #2 Performaing another action
function action3() return 3 end	-- #3 Exception raised
function action4() return 4 end	-- #4 Wildcard in action

TestFSM = {} --class

    function TestFSM:setUp()
		 local myStateTransitionTable1 = {
			{"state1", "event1", "state2", action1},
			{"state2", "event2", "state3", action2}
		}
		
		local myStateTransitionTable2 = {
			{"state1", "event1", "state2", action1},
			{"state2", "event2", "state3", action2},
			{"*"     , "event3", "state1", action4},
			{"*"     , "*",      "state1", action3}
		}
		
		-- creating two different FSM's to test (lack of) interference
		fsm1 = FSM.new(myStateTransitionTable1)	
		fsm2 = FSM.new(myStateTransitionTable2)
		
		fsm1:silent()
		fsm2:silent()
    end
	
	function TestFSM:test1()
	
		assertEquals( FSM.UNKNOWN , "*.*" )
	
		-- Retrieve initial state
		assertEquals( fsm1:get() , "state1" )
		
		-- Set another state
		fsm1:set( "state2" )
		assertEquals( fsm1:get() , "state2" )
		
		-- Respond on "event" and current state
		assertEquals( fsm1:fire("event2"), 2)
		assertEquals( fsm1:get() , "state3" )
		
		-- Force "default" exception for "state3.event3"
		assertEquals( fsm1:fire("event3") , false) 
		assertEquals( fsm1:get() , "state1" )
	end
	
	function TestFSM:test2()
			
		-- Retrieve initial state
		assertEquals( fsm2:get() , "state1" )
		
		-- Set another state
		fsm2:set( "state2" )
		assertEquals( fsm2:get() , "state2" )
		
		-- Respond on "event" and current state
		assertEquals( fsm2:fire("event2"), 2)
		assertEquals( fsm2:get() , "state3" )
		
		-- Force "wildcard" exception "*.event3" => action #4
		assertEquals( fsm2:fire("event3"), 4)
		assertEquals( fsm2:get() , "state1" )
	end
	
	function TestFSM:test3()
			
		fsm2:set( "state2" )
		assertEquals( fsm2:get() , "state2" )
			
		-- Force exception caused by removed state transition
		assertEquals( fsm2:delete({{"state2", "event2"}}), 1) 
		assertEquals( fsm2:fire("event2"), 3 )
		assertEquals( fsm2:get() , "state1" )
		
		-- Remove the exception handler
		assertEquals( fsm2:delete({{"*", "*"}}), 1)

		-- Correcting our mistake
		assertEquals( fsm2:add({{"*", "*", "state2", action3}}), 1)
		assertEquals( fsm2:fire("event2"), 3)
		
	end
-- class TestFSM

LuaUnit:run() -- will execute all tests