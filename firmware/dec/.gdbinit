
python
import sys
import os
if not "has_gdb" in locals():
	print(os.getcwd() + "/dec/gdb/python")
	sys.path.append(os.getcwd() + "/dec/gdb/python")
	has_gdb = True
end
python
from ns import *
end
python
from dbh import *
end
