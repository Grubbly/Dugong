-- lexit.lua                                                                 -
-- Tristan Van Cise                                                          -
-- 02/12/2018                                                                -
-- Programming Languages                                                     -
-- Assignment 3 - Exercise B                                                 -
--                                                                           -
-- Contains lexit module function definitions for lexical analysis.          -
-- The main categories concerned with this specification are keywords,       -
-- identifiers, numeric literals, string literals, operators, punctuation,   -
-- and malformed lexemes. Processing is done using a finite-state-machine    -
-- evaluation scheme with maximal munch (except when preferOpFlag is true)*. -
--                                                                           -
------------------------------------------------------------------------------

local lexit = {}

-- Lexeme Category Numbers --

lexit.KEY = 1
lexit.ID = 2
lexit.NUMLIT = 3
lexit.STRLIT = 4
lexit.OP = 5
lexit.PUNCT = 6
lexit.MAL = 7

preferOpFlag = false -- *Used to force operator evaluation in x+4 like expressions

-- lexit.catnames
-- Table containing the corresponding category names to the
-- constants initialized above
lexit.catnames = { "Keyword", 
                   "Identifier", 
                   "NumericLiteral", 
                   "StringLiteral", 
                   "Operator", 
                   "Punctuation", 
                   "Malformed" }
                 

-- Character Type Identifier Functions --

-- Name: isLetter
--
-- Description: Determines whether or not given parameter is
-- is a character
-- 
function isLetter(character)
  return (character >= 'A' and character <= 'Z') or 
         (character >= 'a' and character <= 'z')
end

-- Name: isDigit
--
-- Description: Determines if parameter is a digit, returns
-- boolean of result
-- 
function isDigit(digit)
  return (digit >= '0' and digit <= '9')
end

-- Name: isWhiteSpace
--
-- Description: Determines if parameter is any variation of
-- a whitespace, returns boolean of result
-- 
function isWhiteSpace(c)
  return c == " " or c == "\t" or c == "\n" or c == "\r"
         or c == "\f";
end

-- Name: isIllegalSymbol
--
-- Description: Determines if parameter is a printable ASCII
-- character, returns boolean of result
-- 
function isIllegalSymbol(sym)
  return (isWhiteSpace(sym) or (sym < ' ' or sym > '~'))
end

-- Name: lexit.preferOp
--
-- Description: Sets the preferOpFlag to true, allowing the
-- lexer to return '+' and '-' as operators and momentarily
-- break the maximal munch rule.
-- 
function lexit.preferOp()
  preferOpFlag = true
end


--LEXER--

-- Name: lexit.lex
--
-- Description: The main lexer fuction that encompasses all lexer
-- functionality. If used correctly in a for-in loop, lexit.lex
-- accepts a string representing a program and iteratively
-- returns every lexeme and its respective category according to
-- the lexeme specification.
-- 
function lexit.lex(program)
  
    -- States --
  local DONE = 0
  local START = 1
  local LETTER = 2
  local DIGIT = 3
  local BANG = 4
  local AND = 5
  local STAR = 6
  local EXPONENT = 7
  local PLUS = 8
  local STRLIT = 9
  
  -- General Lexeme/Lexer Variables --
  local pos
  local state
  local ch
  local lexstr
  local category
  local handlers
  local initialSymbol
  local startingQuoteType --used to match opening/closing ' and "
  
  -- Char Utility Functions --
  
  -- Name: currChar
  --
  -- Description: returns the current character according
  -- to pos, empty if pos is past the end.
  -- 
  local function currChar()
    return program:sub(pos,pos)
  end
  
  -- Name: nextChar
  --
  -- Description: returns the next character without
  -- incrementing the current position in the program string,
  -- empty if pos is past the end.
  -- 
  local function nextChar()
    return program:sub(pos+1,pos+1)
  end
  
  -- Name: nextNextChar
  --
  -- Description: returns the character after next without
  -- incrementing the current position in the program string,
  -- empty if pos is past the end.
  -- 
  local function nextNextChar()
    return program:sub(pos+2,pos+2)
  end
  
  -- Name: drop1
  --
  -- Description: Increments the current position by one
  -- 
  local function drop1()
    pos = pos + 1
  end
  
  -- Name: add1
  --
  -- Description: Concatenates the current character to
  -- lex string, then increments the current position by
  -- one.
  -- 
  local function add1()
    lexstr = lexstr .. currChar()
    drop1()
  end
  
  -- Name: skipWhiteSpace
  --
  -- Description: Skips all forms of whitespace (as determined
  -- by isWhiteSpace function above. If a comment ('#') symbol
  -- is found, all characters are skipped by the lexer until a
  -- '\n' or end of string is found. 
  -- 
  local function skipWhiteSpace()
    while true do
      while isWhiteSpace(currChar()) do
        drop1()
      end
      
      if currChar() ~= '#' then
        break
      end
      
      drop1()
      
      while true do
        if currChar() == "\n" then
          drop1()
          break
        elseif currChar() == "" then
          return
        end
        drop1() --treat the comment like a whitespace
      end
    end
  end      
  
  -- State Handlers --
  
  -- Name: handle_DONE
  --
  -- Description: Notifies client code that an error has occured,
  -- this function should never be executed.
  --
  local function handle_DONE()
    io.write("ERROR (in handle_DONE): Program should not be in this state")
    assert(0)
  end
  
  -- Name: handle_START
  --
  -- Description: Serves as the central starting zone where all future states
  -- can be reached or branched to. This is determined by looking at the first
  -- character and setting the next state accordingly.
  -- 
  local function handle_START()
    if isIllegalSymbol(ch) then
      add1()
      state = DONE
      category = lexit.MAL
    elseif isLetter(ch) or ch == "_" then
      add1()
      state = LETTER
    elseif isDigit(ch) then
      add1()
      state = DIGIT
    elseif ch == '!' or ch == '<' or ch == '>' or ch == '=' then
      add1()
      state = BANG
    elseif ch == '&' or ch == '|' then
      initialSymbol = ch
      add1()
      state = AND
    elseif ch == '*' or ch == '/' or ch == '%' or 
           ch == '[' or ch == ']' or ch == ';' then
      add1()
      state = STAR
    elseif ch == '+' or ch == '-' then
      add1()
      state = PLUS
    elseif ch == '"' or ch == "'" then
      startingQuoteType = ch
      add1()
      state = STRLIT
    else
      add1()
      state = DONE
      category = lexit.PUNCT
    end
  end
  
  -- Name: handle_LETTER
  --
  -- Description: Continuously concatenates valid letters to the current
  -- lexeme. If the the results of the lexeme are equivalent to a keyword,
  -- the string is identified as a keyword, otherwise, it is an identifier. 
  -- 
  local function handle_LETTER()
    if isLetter(ch) or isDigit(ch) or ch == '_' then
      add1()
    else
      state = DONE
      if lexstr == "call" or lexstr == "cr" or lexstr == "else"
         or lexstr == "elseif" or lexstr == "end" or lexstr == "false"
         or lexstr == "func" or lexstr == "if" or lexstr == "input"
         or lexstr == "print" or lexstr == "true" or lexstr == "while" then
        category = lexit.KEY
      else
        category = lexit.ID
      end
    end
  end
  
  -- Name: handle_DIGIT
  --
  -- Description: Concatenates digits onto the current lexeme until an 'e', 'E', or non
  -- digit is found. If 'e' or 'E' is found, only a '+' and other digits may follow it or
  -- else the lexeme is malformed. If any other non digit is found, the lexeme is a numeric
  -- literal.
  --
  -- Note: 'e' and 'E' cases are handled by the exponent state in handle_EXPONENT
  -- 
  local function handle_DIGIT()
    if isDigit(ch) then
      add1()
    elseif (ch == 'e' or ch == 'E') and 
    ((nextChar() == '+' and isDigit(nextNextChar())) or (isDigit(nextChar()))) then 
        add1()
        add1()
        state = EXPONENT
    else
      state = DONE
      category = lexit.NUMLIT
    end
  end

  -- Name: handle_BANG
  -- 
  -- For !, !=, <, <=, >, >=, =, ==
  -- Description: Differentiates between the single symbol operators 
  -- (!, <, >, and =) and single symbol operators followed by '='. 
  -- 
  local function handle_BANG() 
    if ch == '=' then
      add1()
      state = DONE
      category= lexit.OP
    else
      state = DONE
      category = lexit.OP
    end
  end
  
  -- Name: handle_AND
  --
  -- Description: Determines if punctuations '&' or '|' or
  -- operators "&&" or "||" are being used.
  -- 
  local function handle_AND() 
    if ch == initialSymbol then
      add1()
      state = DONE
      category = lexit.OP
    else
      state = DONE
      category = lexit.PUNCT
    end
  end
  
  -- Name: handle_STAR
  --
  -- FOR *, /, %, [, ], and ;
  -- Description: Completes the current lexeme and categorizes
  -- the above symbols as operators
  -- 
  local function handle_STAR() 
    state = DONE
    category = lexit.OP
  end
  
  -- Name: handle_EXPONENT
  --
  -- Description: Continues to concatenate digits to NUMLIT if
  -- an exponent character ('e', 'E', 'e+', 'E+') was used
  -- 
  local function handle_EXPONENT() 
    if isDigit(ch) then
      add1()
    else
      state = DONE
      category = lexit.NUMLIT
    end
  end
  
  -- Name: handle_PLUS
  --
  -- FOR + and -
  -- Description: If the preferOpFlag is set, a '+' or '-' is instantly
  -- categorized as a operator. In all other cases, if a digit follows
  -- the symbol, further lexeme processing is handled by handle_DIGIT().
  -- If only the symbol is present, it is categorized as an operator.
  -- 
  local function handle_PLUS() 
    if preferOpFlag then
      state = DONE
      category = lexit.OP
    elseif isDigit(ch) then
      add1()
      state = DIGIT
    else
      state = DONE
      category = lexit.OP
    end
  end
  
  -- Name: handle_STRLIT
  --
  -- Description: Evaluates string literals denoted by opened and
  -- closed ' or " symbols. Anything can be in a string literal, so
  -- long as the end of program has not been reach or a new line is
  -- present. Concatenation is terminated with the closing version
  -- of the opening symbol used. 
  -- 
  local function handle_STRLIT() -- FOR " and '
    if ch == startingQuoteType then
      add1()
      state = DONE
      category = lexit.STRLIT
    elseif ch == "" or ch == "\n" then
      add1()
      state = DONE
      category = lexit.MAL
    else
      add1()
    end
  end
  
  -- Table that holds state handler functions
  handlers = { 
    [DONE]=handle_DONE, 
    [START]=handle_START, 
    [LETTER]=handle_LETTER, 
    [DIGIT]=handle_DIGIT, 
    [BANG]=handle_BANG,
    [AND]=handle_AND,
    [STAR]=handle_STAR,
    [EXPONENT]=handle_EXPONENT,
    [PLUS]=handle_PLUS,
    [STRLIT]=handle_STRLIT 
  }
  
  -- Name: getLexeme
  --
  -- Description: Main lexer loop that continuously handles state
  -- calls until the state is set to DONE. Uses the table above to
  -- efficiently make calls and returns the lexeme and its category
  -- once evaluation is complete.
  -- 
  -- Note: preferOpFlag is reset to false before return so the closure
  -- does not evaluate every lexer call with preferOpFlag set after its
  -- initial set.
  --
  local function getLexeme(dummy1, dummy2)
    if pos > program:len() then
      preferOpFlag = false
      return nil, nil
    end
    lexstr = ""
    state = START
    while state ~= DONE do
      ch = currChar()
      handlers[state]()
    end
    
    skipWhiteSpace()
    preferOpFlag = false
    return lexstr, category
  end
  
  pos = 1
  skipWhiteSpace()
  return getLexeme, nil, nil
end

return lexit