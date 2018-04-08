-- interpit.lua
-- Tristan Van Cise
-- 04/05/2018
--
-- Interpret AST from parseit.parse
-- For Assignment 6, Exercise B


-- *******************************************************************
-- * To run a Dugong program, use dugong.lua (which uses this file). *
-- *******************************************************************


local interpit = {}  -- Our module


-- ***** Variables *****


-- Symbolic Constants for AST

local STMT_LIST   = 1
local INPUT_STMT  = 2
local PRINT_STMT  = 3
local FUNC_STMT   = 4
local CALL_FUNC   = 5
local IF_STMT     = 6
local WHILE_STMT  = 7
local ASSN_STMT   = 8
local CR_OUT      = 9
local STRLIT_OUT  = 10
local BIN_OP      = 11
local UN_OP       = 12
local NUMLIT_VAL  = 13
local BOOLLIT_VAL = 14
local SIMPLE_VAR  = 15
local ARRAY_VAR   = 16


-- ***** Utility Functions *****


-- numToInt
-- Given a number, return the number rounded toward zero.
local function numToInt(n)
    assert(type(n) == "number")

    if n >= 0 then
        return math.floor(n)
    else
        return math.ceil(n)
    end
end


-- strToNum
-- Given a string, attempt to interpret it as an integer. If this
-- succeeds, return the integer. Otherwise, return 0.
local function strToNum(s)
    assert(type(s) == "string")

    -- Try to do string -> number conversion; make protected call
    -- (pcall), so we can handle errors.
    local success, value = pcall(function() return 0+s end)

    -- Return integer value, or 0 on error.
    if success then
        return numToInt(value)
    else
        return 0
    end
end


-- numToStr
-- Given a number, return its string form.
local function numToStr(n)
    assert(type(n) == "number")

    return ""..n
end


-- boolToInt
-- Given a boolean, return 1 if it is true, 0 if it is false.
local function boolToInt(b)
    assert(type(b) == "boolean")

    if b then
        return 1
    else
        return 0
    end
end


-- astToStr
-- Given an AST, produce a string holding the AST in (roughly) Lua form,
-- with numbers replaced by names of symbolic constants used in parseit.
-- A table is assumed to represent an array.
-- See the Assignment 4 description for the AST Specification.
--
-- THIS FUNCTION IS INTENDED FOR USE IN DEBUGGING ONLY!
-- IT SHOULD NOT BE CALLED IN THE FINAL VERSION OF THE CODE.
function astToStr(x)
    local symbolNames = {
        "STMT_LIST", "INPUT_STMT", "PRINT_STMT", "FUNC_STMT",
        "CALL_FUNC", "IF_STMT", "WHILE_STMT", "ASSN_STMT", "CR_OUT",
        "STRLIT_OUT", "BIN_OP", "UN_OP", "NUMLIT_VAL", "BOOLLIT_VAL",
        "SIMPLE_VAR", "ARRAY_VAR"
    }
    if type(x) == "number" then
        local name = symbolNames[x]
        if name == nil then
            return "<Unknown numerical constant: "..x..">"
        else
            return name
        end
    elseif type(x) == "string" then
        return '"'..x..'"'
    elseif type(x) == "boolean" then
        if x then
            return "true"
        else
            return "false"
        end
    elseif type(x) == "table" then
        local first = true
        local result = "{"
        for k = 1, #x do
            if not first then
                result = result .. ","
            end
            result = result .. astToStr(x[k])
            first = false
        end
        result = result .. "}"
        return result
    elseif type(x) == "nil" then
        return "nil"
    else
        return "<"..type(x)..">"
    end
end


-- ***** Primary Function for Client Code *****


-- interp
-- Interpreter, given AST returned by parseit.parse.
-- Parameters:
--   ast     - AST constructed by parseit.parse
--   state   - Table holding Dugong variables & functions
--             - AST for function xyz is in state.f["xyz"]
--             - Value of simple variable xyz is in state.v["xyz"]
--             - Value of array item xyz[42] is in state.a["xyz"][42]
--   incall  - Function to call for line input
--             - incall() inputs line, returns string with no newline
--   outcall - Function to call for string output
--             - outcall(str) outputs str with no added newline
--             - To print a newline, do outcall("\n")
-- Return Value:
--   state, updated with changed variable values
function interpit.interp(ast, state, incall, outcall)
    -- Each local interpretation function is given the AST for the
    -- portion of the code it is interpreting. The function-wide
    -- versions of state, incall, and outcall may be used. The
    -- function-wide version of state may be modified as appropriate.


    function interp_stmt_list(ast)
        for i = 2, #ast do
            interp_stmt(ast[i])
        end
    end

    function eval_expr(ast)
      
      if (ast[1] == NUMLIT_VAL) then
        return numToInt(strToNum(ast[2]))
        
      elseif ast[1] == SIMPLE_VAR then
        if state.v[ast[2]] ~= nil then
          return state.v[ast[2]]
        else
          return 0
        end
        
      elseif ast[1] == ARRAY_VAR then
         if state.a[ast[2]][ast[3][2]] ~= nil then
          return state.a[ast[2]][ast[3][2]]
        else
          return 0
        end
        
      elseif ast[1] == BOOLLIT_VAL then
        return boolToInt((ast[2] == "true"))
        
      elseif ast[1] == CALL_FUNC then
      	name = ast[2]
        body = state.f[name]
        if body == nil then
            body = { STMT_LIST }
            return 0
        else
            interp_stmt_list(body)
            if state.v["return"] == nil then
            	return 0
            else
            	return state.v["return"]
            end
        end
        
      elseif type(ast[1]) == "table" then
        if ast[1][1] == UN_OP then
          if ast[1][2] == "+" then
            return eval_expr(ast[2])
          elseif ast[1][2] == "-" then
            return -1 * eval_expr(ast[2])
          elseif ast[1][2] == "!" then
            if ast[2][2] == "1" or ast[2][2] == "0" then
              return boolToInt(ast[2][2] ~= "1")
            else
              return 0
            end
          end
          
        elseif ast[1][1] == BIN_OP then
          if ast[1][2] == "+" then
            return numToInt(eval_expr(ast[2]) + eval_expr(ast[3]))
            
          elseif ast[1][2] == "-" then
            return numToInt(eval_expr(ast[2]) - eval_expr(ast[3]))
            
          elseif ast[1][2] == "*" then
            return numToInt(eval_expr(ast[2]) * eval_expr(ast[3]))
            
          elseif ast[1][2] == "/" then
            if ast[3][2] ~= "0" then
              return numToInt(eval_expr(ast[2]) / eval_expr(ast[3]))
            else
              return 0
            end
            
          elseif ast[1][2] == "%" then
            if ast[3][2] ~= "0" then
              return numToInt(eval_expr(ast[2]) % eval_expr(ast[3]))
            else
              return 0
            end
          
          elseif ast[1][2] == "==" then
            return boolToInt(eval_expr(ast[2]) == eval_expr(ast[3]))
          
          elseif ast[1][2] == "!=" then
            return boolToInt(eval_expr(ast[2]) ~= eval_expr(ast[3]))
            
          elseif ast[1][2] == "<" then
            return boolToInt(eval_expr(ast[2]) < eval_expr(ast[3]))
            
          elseif ast[1][2] == "<=" then
            return boolToInt(eval_expr(ast[2]) <= eval_expr(ast[3]))
            
          elseif ast[1][2] == ">" then
            return boolToInt(eval_expr(ast[2]) > eval_expr(ast[3]))
            
          elseif ast[1][2] == ">=" then
            return boolToInt(eval_expr(ast[2]) >= eval_expr(ast[3]))
            
          elseif ast[1][2] == "&&" then
            if ast[2][2] ~= "0" and ast[3][2] ~= "0" then
              return boolToInt(ast[2][2] == ast[3][2])
            else
              return 0
            end
            
          elseif ast[1][2] == "||" then
            return boolToInt(ast[2][2] ~= "0" or ast[3][2] ~= "0")
            
          
          end
        end
      end
    end

    function interp_stmt(ast)
        local name, body, str

        if ast[1] == INPUT_STMT then
            input = numToInt(strToNum(incall()))
            if ast[2][1] == ARRAY_VAR then
              arrayID, index = ast[2][2], strToNum(ast[2][3][2])
              state.a[arrayID][index] = input
            else
              state.v[ast[2][2]] = input
            end
            
        elseif ast[1] == PRINT_STMT then
            for i = 2, #ast do
                if ast[i][1] == CR_OUT then
                    outcall("\n")
                elseif ast[i][1] == STRLIT_OUT then
                    str = ast[i][2]
                    outcall(str:sub(2,str:len()-1))  -- Remove quotes
                else             
                    if ast[i][1] == NUMLIT_VAL then
                      outcall(numToStr(eval_expr(ast[i])))
                      
                    elseif ast[i][1] == SIMPLE_VAR then
                      associatedValue = state.v[ast[i][2]]
                      if associatedValue == nil then
                        outcall("0")
                      else
                        outcall(numToStr(associatedValue))
                      end
                    
                    elseif ast[i][1] == ARRAY_VAR then
                      arrayID, index = ast[i][2], strToNum(ast[i][3][2])
                      if state.a[arrayID] == nil or state.a[arrayID][index] == nil then
                        outcall("0")
                      else
                        outcall(numToStr(state.a[arrayID][index]))
                      end
                    
                    
                    elseif type(ast[i][1]) == "table" then
                      if ast[i][1][1] == UN_OP then
                        outcall(numToStr(eval_expr(ast[i])))
                      else
                        outcall(numToStr(eval_expr(ast[i])))
                      end
                      
                     elseif ast[i][1] == CALL_FUNC then
                     		outcall(numToStr(eval_expr(ast[i])))
                    end
                end
            end
        elseif ast[1] == FUNC_STMT then
            name = ast[2]
            body = ast[3]
            state.f[name] = body
        elseif ast[1] == CALL_FUNC then
            name = ast[2]
            body = state.f[name]
            if body == nil then
                body = { STMT_LIST }  -- Default AST
            end
            interp_stmt_list(body)
        
      elseif ast[1] == IF_STMT then
        nestedIfs = 2
            while true do
            	if ast[nestedIfs+1] == nil or #ast[nestedIfs+1] <= 1 then
            		break
            	end
            
            	if ast[nestedIfs] ~= nil and 
            		 ast[nestedIfs] ~= STMT_LIST and 
            		 eval_expr(ast[nestedIfs]) ~= 0 then
            		interp_stmt_list(ast[nestedIfs+1])
            		break
            	elseif ast[nestedIfs+2] ~= nil and 
            				 ast[nestedIfs+2][1] ~= nil and 
            				 ast[nestedIfs+2][1] == STMT_LIST then
            		interp_stmt_list(ast[nestedIfs+2])
            		break
            	else
            		nestedIfs = nestedIfs + 2
            	end
            end
            
        elseif ast[1] == WHILE_STMT then
        	while true do
            if eval_expr(ast[2]) ~= 0 then
            	interp_stmt_list(ast[3])
            else
            	break
            end
          end
        else
            assert(ast[1] == ASSN_STMT)
            
            rhs = eval_expr(ast[3])
            if ast[2][1] == ARRAY_VAR then
              arrayID, index = ast[2][2], strToNum(ast[2][3][2])
              
              if state.a[arrayID] == nil then
                state.a[arrayID] = {[index]=rhs}
              else
                state.a[arrayID][index] = rhs
              end
              
            else
              state.v[ast[2][2]] = rhs
            end
        end
    end


    -- Body of function interp
    interp_stmt_list(ast)
    return state
end


-- ***** Module Export *****


return interpit

