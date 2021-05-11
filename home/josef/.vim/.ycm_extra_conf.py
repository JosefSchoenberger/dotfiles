# mostly copied from YCM's file
import os

flags = [
# general warnings
'-Wall',
'-Wextra',
'-Wduplicated-cond',
'-Wduplicated-branches',
'-Wlogical-op',
'-Wnull-dereference',
'-Wold-style-cast',
'-Wuseless-cast',
'-Wjump-misses-init',
'-Wshadow=local',
'-Wformat=2',
'-Winit-self', # not default in C
'-Wsuggest-attribute=pure',
'-Wsuggest-attribute=const',
'-Wsuggest-attribute=malloc',
'-Wsuggest-attribute=cold',
'-Walloc-zero',

# Likely to be changed on a per-project basis
'-Wpedantic',
'-Wno-long-long',
#'-Wdouble-promotion', #useful for vecorization
'-Wunsage-loop-optimizations',
#'-Wformat-overflow=2',
'-Wformat-signedness',
'-Wno-empty-translation-unit',
'-Wimplicit-fallthrough=1', #force comment
'-Walloca-larger-than=200',
'-Wframe-larger-than=2048',
'-Wfloat-equal', #disallow == on floats
'-Wundef', #for '#if' on undefined macros
'-Wcast-align',

'-fexceptions',
# '-x', 'c++',
#'-std=gnu++17',
]

include_dirs = [
# paths to be included using '-I'
# e.g. '/usr/include/X11/'
]

# ------------------------------------------------------

# if 'c++' in flags or 'cpp' in flags:
#     include_dirs.append('/usr/include/c++/10/')

flags += list(map(lambda x: '-I' + x, include_dirs))

DIR_OF_THIS_SCRIPT = os.path.abspath( os.path.dirname( __file__ ) )
DIR_OF_THIRD_PARTY = os.path.expanduser('~') + "/.vim/third_party"
SOURCE_EXTENSIONS = [ '.cpp', '.cxx', '.cc', '.c', '.m', '.mm' ]

def IsHeaderFile( filename ):
  extension = os.path.splitext( filename )[ 1 ]
  return extension in [ '.h', '.hxx', '.hpp', '.hh' ]

def FindCorrespondingSourceFile( filename ):
  if IsHeaderFile( filename ):
    basename = os.path.splitext( filename )[ 0 ]
    for extension in SOURCE_EXTENSIONS:
      replacement_file = basename + extension
      if os.path.exists( replacement_file ):
        return replacement_file
  return filename


# return al necessary compilation flags
def Settings( **kwargs ):
  if kwargs[ 'language' ] == 'cfamily':
    filename = FindCorrespondingSourceFile( kwargs[ 'filename' ] )

    result = {
            'flags': flags,
            'override_filename': filename
            }
    if DIR_OF_THIS_SCRIPT != os.path.expanduser('~') + "/.vim":
        result = {**result, **{
            'include_paths_relative_to_dir': DIR_OF_THIS_SCRIPT
        }}

    return result
  return {}
