#!/bin/sh
## myscript.sh for  in /Users/pouchet/inria/projects/pocc/polybenchs/svn-inria/polybenchs/branches/flag-exploration
## 
## Made by Louis-Noel Pouchet
## Contact: <pouchet@cse.ohio-state.edu>
## 
## Started on  Fri Jul  9 15:11:22 2010 Louis-Noel Pouchet
## Last update Tue Jul 13 23:56:10 2010 Louis-Noel Pouchet
##

create_archive()
{
    category="$1";
    bench="$2";
    echo "** Creating archive for versions of $category/$bench";
    cd $category/$bench && rm -f $bench-pocc-flags.tar.gz; tar czf $bench-pocc-flags.tar.gz $bench-pocc-flags; svn add $bench-pocc-flags.tar.gz; svn add $bench.c-similar-versions;  cd -
}

create_versions()
{
    category="$1";
    bench="$2";
    echo "** Generating versions for $category/$bench";
    cd $category/$bench && pocc-util generate-versions ~/inria/projects/pocc/versions-v2.txt $bench.c; cd -
}

for bench in covariance correlation; do
    create_versions datamining $bench
    create_archive datamining $bench    
done;

for bench in 2mm bicg gemm mvt syrk 3mm cholesky gemver symm trisolv atax doitgen gesummv syr2k trmm; do
    create_versions linear-algebra/kernels $bench
    create_archive linear-algebra/kernels $bench    
done;

for bench in durbin dynprog gramschmidt lu ludcmp; do
    create_versions linear-algebra/solvers $bench
    create_archive linear-algebra/solvers $bench    
done;

for bench in adi fdtd-apml  fdtd-2d  seidel; do #jacobi-* are bugged
    create_versions stencils $bench
    create_archive stencils $bench    
done;

for bench in gauss-filter reg_detect; do
    create_versions image-processing $bench
    create_archive image-processing $bench    
done;
