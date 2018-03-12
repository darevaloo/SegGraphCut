using JuMP
using Mosek
clearconsole()
n=8
#MatrizFlujo=[0.0 0  0 0 0 0;4 0 0 0 0 0;2 0 0 1 0 0;0 3 2 0 0 0;0 0 3 0 0 0;0 0 0 2 4 0]'
MatrizFlujo=zeros(n,n)
MatrizFlujo[1,2]=8
MatrizFlujo[1,3]=7
MatrizFlujo[1,4]=4
MatrizFlujo[2,3]=2
MatrizFlujo[2,5]=3
MatrizFlujo[2,6]=9
MatrizFlujo[3,4]=5
MatrizFlujo[3,6]=6
MatrizFlujo[4,6]=7

MatrizFlujo[4,7]=2
MatrizFlujo[5,8]=9
MatrizFlujo[6,5]=3
MatrizFlujo[6,8]=5
MatrizFlujo[6,7]=4
MatrizFlujo[7,8]=8
println(MatrizFlujo)

#MatrizFlujo=round.(10*rand(n,n),0)
println(MatrizFlujo)
m=Model(solver = MosekSolver())
@variable(m,x[1:n,1:n]>=0)
for i= 2:n-1
    a = zero(AffExpr)
    for j = 1 : n
        if MatrizFlujo[i,j]>0.0
            a += -x[i,j]
        end
        if MatrizFlujo[j,i]>0.0
            a += x[j,i]
        end
    end
    @constraint(m,a==0)
end
for i = 1: n
    for j=1: n
        if MatrizFlujo[i,j]>0
            @constraint(m,x[i,j]<=MatrizFlujo[i,j])
        end
    end
end
a = zero(AffExpr)
for j = 1: n-1
    if MatrizFlujo[1,j]>0
        a+= x[1,j]
    end
end
@objective(m,Max,a)
status = solve(m)
println("Objective value: ", getobjectivevalue(m))
for i=1:n
    for j=1:n
        d= getvalue(x[i,j])
        if d>0
            println("El flujo de la arista ", i, " a ", j," es: ",d)
        end
    end
end

println(getvalue(x))
