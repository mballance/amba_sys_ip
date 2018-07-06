#!/bin/python
import os.path
import sys
import subprocess

# Subcommands
# update: 
# - discovers the project location by finding ivpm.info
# - locates the packages.info file
# - Processes the existing packages (if any)
#   - Load the packages.mf file from the packages directory
# - For each package in the package.info file:
#   - If the selected package is not source
#     - Locate the package.mf file from the repositories
#   - Otherwise,
#
#   - Check the package vers 

# Discover location
# Need to determine the project that we're in

class proj_info:
    def __init__(self, is_src):
        self.is_src = is_src
        self.dependencies = []

    def add_dependency(self, dep):
        self.dependencies.append(dep)
        
    def deps(self):
        return self.dependencies

#********************************************************************
#* read_packages
#*
#* Read the content of a packages.info file and return a dictionary
#* with an entry per package with a non-null 
#********************************************************************
def read_packages(packages_mf):
    packages = {}
    
    fh = open(packages_mf, "rb")

    for l in fh.readlines():
        l = l.strip()
        
        comment_idx = l.find("#")
        if comment_idx != -1:
            l = l[0:comment_idx]
        
        if l == "":
            continue
        
        at_idx = l.find("@")
        if at_idx != -1:
            package=l[0:at_idx].strip()
            src=l[at_idx+1:len(l)].strip()
        else:
            package=l
            src=None
     
        if package in packages.keys():
            print("Error: multiple package listings")
            
        packages[package] = src
    
    fh.close()
    
    return packages

#********************************************************************
# write_packages
#********************************************************************
def write_packages(packages_mf, packages):
  fh = open(packages_mf, "w")

  for package in packages.keys():
    fh.write(package + "@" + packages[package] + "\n")

  fh.close()
  
#********************************************************************
# write_packages_mk
#********************************************************************
def write_packages_mk(
        packages_mk, 
        project,
        package_deps):
  
  fh = open(packages_mk, "w")
  fh.write("#********************************************************************\n");
  fh.write("# packages.mk for " + project + "\n");
  fh.write("#********************************************************************\n");
  fh.write("\n");
  fh.write("ifneq (1,$(RULES))\n");
  fh.write("package_deps = " + project + "\n")
  for p in package_deps.keys():
      info = package_deps[p]
      fh.write(p + "_deps=")
      for d in info.deps():
          fh.write(d + " ")
      fh.write("\n")
      fh.write(p + "_clean_deps=")
      for d in info.deps():
          fh.write("clean_" + d + " ")
      fh.write("\n")

  fh.write("else # Rules\n");
  for p in package_deps.keys():
      info = package_deps[p]
      fh.write(p + " : $(" + p + "_deps)\n");
     
      if info.is_src:
          fh.write("\t$(Q)$(MAKE) PACKAGES_DIR=$(PACKAGES_DIR) PHASE2=true -C $(PACKAGES_DIR)/" + p + "/scripts -f ivpm.mk build\n")
      fh.write("\n");
      fh.write("clean_" + p + " : $(" + p + "_clean_deps)\n");
     
      if info.is_src:
          fh.write("\t$(Q)$(MAKE) PACKAGES_DIR=$(PACKAGES_DIR) PHASE2=true -C $(PACKAGES_DIR)/" + p + "/scripts -f ivpm.mk clean\n")
      fh.write("\n");

  fh.write("\n")
  fh.write("endif\n");
  fh.write("\n")
  
  fh.close()
    
#********************************************************************
# read_info
#
# Reads an .info file, which has the format key=value
#********************************************************************
def read_info(info_file):
    info = {}
    
    fh = open(info_file, "rb")

    for l in fh.readlines():
        l = l.strip()
        
        comment_idx = l.find("#")
        if comment_idx != -1:
            l = l[0:comment_idx]
        
        if l == "":
            continue
        
        eq_idx = l.find("=")
        if eq_idx != -1:
            key=l[0:eq_idx].strip()
            src=l[eq_idx+1:len(l)].strip()
            info[key] = src
        else:
            print("Error: malformed line \"" + l + "\" in " + info_file);
     
    fh.close()
    
    return info

        
#********************************************************************
# update_package()
#
# package      - the name of the package to update
# packages_mf  - the packages/packages.mf file
# packages     - the packages.mf file for this package
# package_deps - a dict of package-name to package_info
#********************************************************************
def update_package(
	package,
    packages_mf,
	dependencies,
	packages_dir,
    package_deps
	):
  package_src = dependencies[package]
  must_update=False
  
  print "********************************************************************"
  print "Processing package " + package + ""
  print "********************************************************************"
  

  if package in packages_mf.keys():
    # See if we are up-to-date or require a change
    if os.path.isdir(packages_dir + "/" + package) == False:
        must_update = True
    elif packages_mf[package] != dependencies[package]:
        # TODO: should check if we are switching from binary to source
        print "Removing existing package dir for " + package
        sys.stdout.flush()
        os.system("rm -rf " + packages_dir + "/" + package)
        print "PackagesMF: " + packages_mf[package] + " != " + dependencies[package]
        must_update = True
  else:
    must_update = True
    
  if must_update:
    # Package isn't currently present in dependencies
    scheme_idx = package_src.find("://")
    scheme = package_src[0:scheme_idx+3]
    print "Must add package " + package + " scheme=" + scheme
    if scheme == "file://":
      path = package_src[scheme_idx+3:len(package_src)]
      cwd = os.getcwd()
      os.chdir(packages_dir)
      sys.stdout.flush()
      status = os.system("tar xvzf " + path)
      os.chdir(cwd)
      
      if status != 0:
          print "Error: while unpacking " + package
          
      print "File: " + path
    elif scheme == "http://" or scheme == "https://":
      ext_idx = package_src.rfind('.')
      if ext_idx == -1:
          print "Error: URL resource doesn't have an extension"
      ext = package_src[ext_idx:len(package_src)]
      if ext == ".git":
          cwd = os.getcwd()
          os.chdir(packages_dir)
          sys.stdout.flush()
          status = os.system("git clone " + package_src)
          os.chdir(cwd)
          os.chdir(packages_dir + "/" + package)
          sys.stdout.flush()
          status = os.system("git submodule update --init --recursive")
          os.chdir(cwd)
      elif ext == ".gz":
        # Just assume this is a .tar.gz
        cwd = os.getcwd()
        os.chdir(packages_dir)
        sys.stdout.flush()
        os.system("wget -O " + package + ".tar.gz " + package_src)
        os.system("tar xvzf " + package + ".tar.gz")
        os.system("rm -rf " + package + ".tar.gz")
        os.chdir(cwd)
      else:
          print "Error: unknown URL extension \"" + ext + "\""
      print "URL"
    else:
        print "Error: unknown scheme " + scheme

  this_package_mf = read_packages(packages_dir + "/" + package + "/etc/packages.mf")
 
  # This is a source package, so keep track so we can properly build it 
  is_src = os.path.isfile(packages_dir + "/" + package + "/scripts/ivpm.mk")
  
  # Add a new entry for this package
  info = proj_info(is_src)
  package_deps[package] = info
  
  for p in this_package_mf.keys():
      print "Dependency: " + p
      info.add_dependency(p)
      if p in dependencies.keys():
        print "  ... has already been handled"
      else:
        print "  ... loading now"
        # Add the new package to the full dependency list we're building
        dependencies[p] = this_package_mf[p]
        
        update_package(
  	      p,            # The package to upate
          packages_mf,  # The dependencies/dependencies.mf input file
	      dependencies, # The dependencies/dependencies.mf output file 
	      packages_dir, # Path to dependencies
          package_deps) # Dependency information for each file
     


#********************************************************************
# update()
#********************************************************************
def update(project_dir, info):
    etc_dir = project_dir + "/etc"
    packages_dir = project_dir + "/packages"
    packages_mf = {}
    # Map between project name and proj_info
    package_deps = {}

    if os.path.isdir(packages_dir) == False:
      os.makedirs(packages_dir);
    else:
      if os.path.isfile(packages_dir + "/packages.mf"):
        packages_mf = read_packages(packages_dir + "/packages.mf")
      else:
        print "Error: no packages.mf file"
  
    print "update"

    # Load the root project dependencies
    dependencies = read_packages(etc_dir + "/packages.mf")
    
    # Add an entry for the root project
    pinfo = proj_info(False)
    for d in dependencies.keys():
        pinfo.add_dependency(d)
    package_deps[info["name"]] = pinfo

    for pkg in dependencies.keys():
      update_package(
	    pkg, 
        packages_mf,
	    dependencies, 
	    packages_dir,
        package_deps)

    write_packages(packages_dir + "/packages.mf", dependencies)
    write_packages_mk(packages_dir + "/packages.mk", info["name"], package_deps)
    

#********************************************************************
# main()
#********************************************************************
def main():
    scripts_dir = os.path.dirname(os.path.realpath(__file__))
    project_dir = os.path.dirname(scripts_dir)
    etc_dir = os.path.dirname(scripts_dir) + "/etc"
    packages_dir = os.path.dirname(scripts_dir) + "/packages"
    
    if os.path.isfile(etc_dir + "/ivpm.info") == False:
        print("Error: no ivpm.info file in the etc directory ("+etc_dir+")")
        exit(1)

    if os.path.isfile(etc_dir + "/packages.mf") == False:
        print("Error: no packages.mf file in the etc directory ("+etc_dir+")")
        exit(1)
    
    if len(sys.argv) < 2:
        print("Error: too few args")
        exit(1)
        
    cmd = sys.argv[1]

    info = read_info(etc_dir + "/ivpm.info");
    
    if cmd == "update":
        update(project_dir, info)
    elif cmd == "build":
        print("Build")
    else:
        print("Error: " + cmd)
        
    
    print "Package: " + info["name"];
    print "Version: " + info["version"];

    # Load the root dependencies
#    for d in dependencies.keys():
#      print "Dependency: package=" + d + " " + dependencies[d];
    
if __name__ == "__main__":
    main()



