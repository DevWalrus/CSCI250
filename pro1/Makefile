#
# Makefile for CompOrg Experiment 1 - sudoku
#

#
# Location of the processing programs
#
RASM  = /home/fac/wrc/bin/rasm
RLINK = /home/fac/wrc/bin/rlink

#
# Suffixes to be used or created
#
.SUFFIXES:	.asm .obj .lst .out

#
# Object files to be created
#
OBJECTS = sudoku.obj utils.obj solve.obj
# INVALID = sudoku.obj invalid_utils.obj solve.obj
# ERROR = sudoku.obj error_utils.obj solve.obj

#
# Transformation rule: .asm into .obj
#
.asm.obj:
	$(RASM) -l $*.asm > $*.lst

#
# Transformation rule: .obj into .out
#
.obj.out:
	$(RLINK) -o $*.out $*.obj > $*.map

#
# Main target
#
sudoku.out: $(OBJECTS)
	$(RLINK) -m -o $*.out $(OBJECTS) > $*.map

clean:
	rm *.out *.lst *.obj *.map

#invalid:
#	$(RLINK) -m -o $*.out $(INVALID) > $*.map

#error:
#	$(RLINK) -m -o $*.out $(ERROR) > $*.map
