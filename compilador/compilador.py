import sys

# Abro archivo
# Separo por lineas
# Creo archivo .mif e inicializo
# Mando linea a linea a un parser
#   Se fija si existe el prefix
#   Se fija si estan bien los argumentos
#   Devuelve opcode en binario
#   Pongo el opcode en el mif (Me fijo en que posicion lo pongo???)
# Devuelvo el mif


# Recibo nombre del programa de entrada (opcional del mif)

errortype = {
    0: "No error",
    1: "Registro Exedido",
    2: "No existe opcode",
    3: "Argumentos extra",
    4: "Argumento invalido",
    5: "Faltan Argumentos"

}

operationsIndexes = {

    "ANDK" : 1,
    "ORK"  : 2,
    "ADDK" : 3,
    "XORK" : 4,
    "SUBK" : 5,
    "MULK" : 6,
    "DIVK" : 7,
    "MODK" : 8,

    "ANDWR" : 2,
    "ORWR"  : 3,
    "ADDWR" : 4,
    "XORWR" : 5,
    "SUBWR" : 6,
    "MULWR" : 7,
    "DIVWR" : 8,
    "MODWR" : 9,
    "ADDCWR" : 10,
    "LSHWR" : 11,
    "RSHWR": 12,

    "ADDGR" :0,
    "ANDGR" : 7,
    "ORGR"  : 8,
    "XORGR" : 9,
    "SUBGR" : 10,
    "MULGR" : 11,
    "DIVGR" : 12,
    "MODGR" : 13,
    "LSHGR" : 14,
    "RSHGR": 15,


}


def decomposeOperand(operand):

    error = 0
    operandType = operand[0]
    operandNumber = 0


    if operandType == 'P':
        operandType = operandType + operand[1]
        operandNumber = int(operand[2:])
        if operandNumber<=1:
            if operandType == 'PI':
                operandNumber = operandNumber + 28
            elif operandType =='PO':
                operandNumber = operandNumber + 30
        else:
            error = 1

    elif operandType == 'W':

        operandNumber = 0  #REVISAR

    elif operandType == 'R':

        operandNumber = int(operand [1:])
        if operandNumber>27:
            error = 1

    elif operandType == '!':
        operandNumber = int(operand[1:])
        if operandNumber>((2**16)-1):
            error = 1
    elif operandType == 'C':
        operandType = operandType + operand[1]




    return operandType,operandNumber,error

def binaryInstructionPrefix(instructionType):

    binPrefix = 1
    if instructionType == "Direct":
        binPrefix = binPrefix<<23
    elif instructionType == "Constant":
        binPrefix = binPrefix << 22
    elif instructionType == "Work Register":
        binPrefix = binPrefix << 21
    elif instructionType == "General Register":
        binPrefix = binPrefix << 20
    elif instructionType == "Other":
        binPrefix = binPrefix << 19

    return binPrefix


def lsbCreator(firstArg,secondArg):
    binInst = 0b000000000000000000000000
    aux = firstArg<<5
    binInst = binInst|aux|secondArg
    return binInst


def operatorInstructionCreator(arguments,constantIndexKEY,workRegisterIndexKEY,generalRegisterIndexKEY):

    constantIndex = operationsIndexes[constantIndexKEY]
    workRegisterIndex = operationsIndexes[workRegisterIndexKEY]
    generalRegisterIndex = operationsIndexes[generalRegisterIndexKEY]
    operand1 = arguments[0]
    operand2 = arguments[1]
    error = 0
    threeArgs = False
    opType1, opNumber1, error = decomposeOperand(operand1)
    opType2, opNumber2, error = decomposeOperand(operand2)

    if len(arguments) > 2:
        operand3 = arguments[2]
        opType3, opNumber3, error = decomposeOperand(operand3)
        threeArgs = True

    binInst = 0b000000000000000000000000

    if opType1 == 'W':
        if opType2 == '!':
            binInst, error = ConstantTypeSolver(opType2,opNumber2,error, constantIndex)
        elif opType2 == 'R':
            binInst = binInst | (workRegisterIndex << 5) | binaryInstructionPrefix("Work Register") | lsbCreator(opNumber1, opNumber2)  # Con opType W el number es 0

        else:
            error = 4
    elif opType1 == 'R':
        if threeArgs:
            if opType2 == 'W' and opType3 == 'R':
                binInst = binInst | (generalRegisterIndex << 10) | binaryInstructionPrefix("General Register") | lsbCreator(opNumber1,opNumber3)

            else:
                error = 4
        elif opType2 == 'W':
            #Solo se llega a este caso si la operacion es un shift
            LSHval = operationsIndexes["LSHGR"]
            RSHval = operationsIndexes["RSHGR"]
            if generalRegisterIndex ==LSHval or generalRegisterIndex == RSHval:
                binInst = binInst | (generalRegisterIndex << 10) | binaryInstructionPrefix("General Register") | lsbCreator(opNumber1, opNumber2)
            else:
                error = 5  # NO es operacion de shift y le faltan argumentos

        else:
            error = 5
    return binInst,error

def JumpTypeSolver(arguments):
    binInst = 0b000000000000000000000000
    error = 0
    operand = arguments[0]
    opType,opNumber,error = decomposeOperand(operand)
    if opNumber <= ((2 ** 12) - 1):
        binInst = binInst | binaryInstructionPrefix("Direct") | opNumber
    else:
        error = 1

    return binInst, error

def ConstantTypeSolver(opType,K,error,funcIndex):

    binInst = 0b000000000000000000000000
   # opType,K,error = decomposeOperand(arguments)

    if opType == '!' and int(K<=((2**16)-1)):
        aux = funcIndex<<16
        binInst = binaryInstructionPrefix("Constant")| K | aux

    else:
        error = 4
    return binInst,error

def MOVCallback(arguments):   #Deberia llamarse register solver! Para adaptar con las otras operaciones
    operand1 = arguments[0]
    operand2 = arguments[1]

    error = 0

    opType1, opNumber1,error = decomposeOperand(operand1)
    opType2, opNumber2,error = decomposeOperand(operand2)
    binInst = 0b000000000000000000000000

    if(error==0):

        if opType1 == 'W':
            binInst = binInst|(binaryInstructionPrefix("Work Register"))
            if opType2 == 'R':
                binInst = binInst|(opNumber2)
            elif opType2 == 'PI':
                aux = 1<<5  #DUDA NUMEROO
                binInst = binInst | (aux)|(opNumber2)
            else:
                error = 4

        elif opType1 == 'R':
            binInst = binInst | (binaryInstructionPrefix("General Register"))
            aux = opNumber1 << 5
            binInst = binInst | (aux)
            if opType2 == 'R':
                aux2 = 1<<10  #MAGIC NUMBER
                binInst = binInst | (opNumber2)|(aux2)
            elif opType2 == 'PI':
                 aux2 = 3<<10  #MAGIC NUMBER
                 binInst = binInst|(opNumber2)|(aux2)
            elif opType2 == 'W':
                aux2 = 5<<10  #MAGIC NUMBER
                binInst = binInst|(opNumber2)|(aux)|(aux2)

        elif opType1 == 'PO':
            binInst = binInst | (binaryInstructionPrefix("General Register"))
            aux = opNumber1 << 5
            binInst = binInst | (aux)
            if opType2 == 'R':
                aux2 = 2<<10  #MAGIC NUMBER
                binInst = binInst | (opNumber2)|(aux2)

            elif opType2 == 'PI':
                aux2 = 4<<10  #MAGIC NUMBER
                binInst = binInst|(opNumber2)|(aux2)

            elif opType2 == 'W':
                aux2 = 6<<10  #MAGIC NUMBER
                binInst = binInst|(opNumber2)|(aux)|(aux2)


    return binInst,error

def JMPCallback(arguments):

    binInst,error = JumpTypeSolver(arguments)
    return binInst,error

def JZECallback(arguments):
    binInst,error = JumpTypeSolver(arguments)
    aux = 1<<12
    binInst = binInst|aux
    return binInst, error
def JNECallback(arguments):
    binInst,error = JumpTypeSolver(arguments)
    aux = 2<<12
    binInst = binInst|aux
    return binInst, error
def JCYCallback(arguments):
    binInst, error = JumpTypeSolver(arguments)
    aux = 3 << 12
    binInst = binInst | aux
    return binInst, error
def RETCallback(arguments):
    error = 0
    binInst = binaryInstructionPrefix("Direct")
    aux = 4 << 12
    binInst = binInst | aux
    return binInst, error
def BSRCallback(arguments):
    binInst, error = JumpTypeSolver(arguments)
    aux = 5 << 12
    binInst = binInst | aux
    return binInst, error

def MOMCallback(arguments):
    error = 0
    binInst = 0
    aux = 0
    opNumber = 0
    if arguments[0] == 'W':
        opType, opNumber, error = decomposeOperand(arguments[1])
        aux = 7 << 12
    elif arguments[1] == 'W':

        opType, opNumber, error = decomposeOperand(arguments[0])
        aux = 6 << 12
    else:
        error = 4

    if opNumber <= ((2 ** 12) - 1):
        binInst = binInst | binaryInstructionPrefix("Direct") | opNumber
    else:
        error = 1

    binInst = binInst | aux
    return binInst, error


def MOKCallback(arguments):
    operand1 = arguments[0]
    operand2 = arguments[1]
    opType1, opNumber1, error = decomposeOperand(operand1)
    opType2, opNumber2, error = decomposeOperand(operand2)
    error = 0
    binInst = 0
    if opType1 == 'W':
        binInst,error = ConstantTypeSolver(opType2,opNumber2,error,0)
    else:
        error = 4

    return binInst,error
# def ANKCallback(arguments):
#     binInst,error = ConstantTypeSolver(arguments,1)
#     return binInst,error
# def ORKCallback(arguments):
#     binInst,error = ConstantTypeSolver(arguments,2)
#     return binInst,error
# def ADKCallback(arguments):
#     binInst,error = ConstantTypeSolver(arguments,3)
#     return binInst,error

def ANDCallback(arguments):
    binInst, error = operatorInstructionCreator(arguments, "ANDK", "ANDWR", "ANDGR")

    return binInst, error

def ORCallback(arguments):
    binInst, error = operatorInstructionCreator(arguments, "ORK", "ORWR", "ORGR")

    return binInst, error

def ADDCallback(arguments):
    binInst, error = operatorInstructionCreator(arguments, "ADDK", "ADDWR", "ADDGR")

    return binInst, error

def ADDCCallback(arguments):
    binInst, error = operatorInstructionCreator(arguments, "ANDK", "ADDCWR", "ANDGR")

    return binInst, error


def XORCallback(arguments):
    binInst, error = operatorInstructionCreator(arguments, "XORK", "XORWR", "XORGR")

    return binInst, error

def MULCallback(arguments):

    binInst,error = operatorInstructionCreator(arguments,"MULK","MULWR","MULGR")
    # operand1 = arguments[0]
    # operand2 = arguments[1]
    # error = 0
    # threeArgs = False
    # opType1, opNumber1, error = decomposeOperand(operand1)
    # opType2, opNumber2, error = decomposeOperand(operand2)
    #
    # if len(arguments)>2:
    #     operand3 = arguments[2]
    #     opType3,opNumber3,error = decomposeOperand(operand3)
    #     threeArgs = True
    #
    # binInst = 0b000000000000000000000000
    #
    # if opType1 =='W':
    #     if opType2 =='!':
    #         binInst,error = ConstantTypeSolver(arguments[1],6)
    #     elif opType2 == 'R':
    #         binInst = binInst|(7<<5)|binaryInstructionPrefix("Work Register")|lsbCreator(opNumber1,opNumber2)    # Con opType W el number es 0
    #     else:
    #         error = 4
    # elif opType1 == 'R' :
    #     if threeArgs:
    #         if opType2 == 'W' and opType3 == 'R':
    #             binInst = binInst|(11<<10)| binaryInstructionPrefix("General Register")|lsbCreator(opNumber1,opNumber3)
    #         else:
    #             error = 4
    #     else:
    #         error = 5
    #
    return binInst,error



def DIVCallback(arguments):
    binInst, error = operatorInstructionCreator(arguments, "DIVK", "DIVWR", "DIVGR")

    return binInst, error
def MODCallback(arguments):
    binInst, error = operatorInstructionCreator(arguments, "MODK", "MODWR", "MODGR")

    return binInst, error

def RSHCallback(arguments):
    binInst, error = operatorInstructionCreator(arguments, "MODK", "RSHWR", "RSHGR") #MODK NUNCA DEBERIA SER USADO

    return binInst, error

def LSHCallback(arguments):
    binInst, error = operatorInstructionCreator(arguments, "MODK", "LSHWR", "LSHGR") #MODK NUNCA DEBERIA SER USADO

    return binInst, error

def SUBCallback(arguments):
    binInst, error = operatorInstructionCreator(arguments, "SUBK", "SUBWR", "SUBGR")

    return binInst, error

def NOPCallback(arguments):
    #binInst, error = operatorInstructionCreator(arguments, "SUBK", "SUBWR", "SUBGR")
    binInst = 0b000000000000000000000000|binaryInstructionPrefix("Other")|2
    error = 0
    return binInst, error

def CLRCallback(arguments):
    #binInst, error = operatorInstructionCreator(arguments, "SUBK", "SUBWR", "SUBGR")
    operand = arguments[0]
    opType,opNumber,error = decomposeOperand(operand)
    if opType =='CY':
        binInst = 0b000000000000000000000000|binaryInstructionPrefix("Other")|4
        error = 0
    else:
        binInst =0
        error = 4
    return binInst, error


def CPLCallback(arguments):
    # binInst, error = operatorInstructionCreator(arguments, "SUBK", "SUBWR", "SUBGR")
    operand = arguments[0]
    opType, opNumber, error = decomposeOperand(operand)
    if opType == 'W':
        binInst = 0b000000000000000000000000 | binaryInstructionPrefix("Other") | 3
        error = 0
    else:
        binInst = 0
        error = 4
    return binInst, error

def SETCallback(arguments):
    #binInst, error = operatorInstructionCreator(arguments, "SUBK", "SUBWR", "SUBGR")
    operand = arguments[0]
    opType,opNumber,error = decomposeOperand(operand)
    if opType =='CY':
        binInst = 0b000000000000000000000000|binaryInstructionPrefix("Other")|7
        error = 0
    else:
        binInst =0
        error = 4
    return binInst, error



opcodes = {

    "MOV": MOVCallback,
    "JMP": JMPCallback,
    "JZE": JZECallback,
    "JNE": JNECallback,
    "JCY": JCYCallback,
    "RET": RETCallback,
    "BSR": BSRCallback,
    "MOM": MOMCallback,
    "MOK": MOKCallback,
    "AND": ANDCallback,
    "OR": ORCallback,
    "ADD": ADDCallback,
    "ADDC" : ADDCCallback,
    "XOR" : XORCallback,
    "SUB" : SUBCallback,
    "MUL" : MULCallback,
    "DIV" : DIVCallback,
    "MOD" : MODCallback,
    "LSH" : LSHCallback,
    "RSH" : RSHCallback,
    "NOP" : NOPCallback,
    "CPL" : CPLCallback,
    "CLR" : CLRCallback,
    "SET" : SETCallback

}


def parseOpcodeLine(opcodeLine):
    opcodeLineUniform = opcodeLine.replace(',',' ')
    splitedLine = opcodeLineUniform.split()
    opcode = splitedLine[0]
    arguments = splitedLine[1:]

    #opcodes.get(opcode,default)(arguments)
    if opcode in opcodes:
        binaryInst,error = opcodes[opcode](arguments)
    else:
        error = 3
        binaryInst =0

    return binaryInst,error


inputFile, outputFile = sys.argv[1:]

f = open(inputFile,"r")
objCode = open(outputFile,"w")

code = f.readlines()

lineCounter = 0

for opcodeLine in code:
    if(opcodeLine != '\n'):
        binaryInstruction,error = parseOpcodeLine(opcodeLine)
        if (error!= 0):
            print("ERROR EN LA LINEA: ", lineCounter, errortype[error])
            binaryInstruction = 0
            break
        #objCode.write(f"{binaryInstruction:024b}")
        objCode.write(f"{binaryInstruction:6x}")
        objCode.write("\n")
        lineCounter= lineCounter+1

