using JuMP
using Clp
n=6
MatrizFlujo=[0.0 4  2 0 0 0;0 0 0 3 0 0;0 0 0 2 3 0;0 0 1 0 0 2;0 0 0 0 0 4;0 0 0 0 0 0]
m=Model(solver = ClpSolver())
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
MFMaximo=getvalue(x)


#### En esta parte se calcula la particion del grafo
#### El conjunto "Alcanzables" va contener los vertices del grafo que forman la "mitad" de la particion
Alcanzables=Set{Int32}()
push!(Alcanzables,1)
tmAlc=length(Alcanzables)
r=0
while (tmAlc>r)
    r=tmAlc
    for x in Alcanzables
        if x>0 & x<=n
            for i=1:n
                if MatrizFlujo[x,i]-MFMaximo[x,i]>0
                    push!(Alcanzables,i)
                end
                if MFMaximo[i,x]>0
                    push!(Alcanzables,i)
                end
            end
        end
    end
    tmAlc=length(Alcanzables)
end
print(Alcanzables)
