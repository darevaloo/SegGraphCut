using JuMP
using Clp
clearconsole()
##Dimensiones de la matriz adyacencia del grafo
## N: vertices
N=n*m
#MatrizFlujo=[['s',1,20],[8,'t',20],[1,2,8],[1,3,7],[1,4,4],[2,3,2],[2,5,3],[2,6,9],[3,4,5],[3,6,6],[4,6,7],[4,7,2],[5,8,9],[6,5,3],[6,8,5],[6,7,4],[7,8,8]]
MatrizFlujo=MG
tam=length(MatrizFlujo)
SalidaFlujo = Dict()

for (i,e) in enumerate(MatrizFlujo)
    ind=get(SalidaFlujo, e[1], -1)
    if ind != -1
        push!(SalidaFlujo[e[1]],i)
    else
        push!(SalidaFlujo,e[1]=> [i])
    end
end

EntradaFlujo = Dict()

for (i,e) in enumerate(MatrizFlujo)
    ind=get(EntradaFlujo, e[2], -1)
    if ind != -1
        push!(EntradaFlujo[e[2]],i)
    else
        push!(EntradaFlujo,e[2]=> [i])
    end
end

modelo=Model(solver = ClpSolver())
@variable(modelo,x[1:tam]>=0)
for i = 1:N
    a = zero(AffExpr)
    if !isempty(SalidaFlujo[i])
        for k in SalidaFlujo[i]
            a += -x[k]
        end
    end
    if !isempty(EntradaFlujo[i])
        for k in EntradaFlujo[i]
            a += x[k]
        end
    end
    @constraint(modelo,a==0)
end

for (k,e) in enumerate(MatrizFlujo)
    @constraint(modelo,x[k] <= e[3])
end
a = zero(AffExpr)
for k in SalidaFlujo['s']
    a+=x[k]
end
@objective(modelo,Max,a)
status = solve(modelo)
println("Objective value: ", getobjectivevalue(modelo))

#for (i,e) in enumerate(MatrizFlujo)
#   d=getvalue(x[i])
#   println("El flujo de la arista ", e[1], " a ", e[2]," es: ",d)
#end

##Esta matriz contiene la asignación optima del
##problema
MFMaximo=getvalue(x)

### En esta parte se calcula la particion del grafo
### El conjunto "Alcanzables" va contener los vertices
### del grafo que forman la "mitad" de la particion

Alcanzables=Set{Any}('s')
tmAlc=length(Alcanzables)
r=0

while (tmAlc>r)
    r=tmAlc
    NewAlcanzables = Set{Any}()
    for z in Alcanzables
        X_out= get(SalidaFlujo,z,[])
        if !isempty(X_out)
            for k in X_out
                if (MatrizFlujo[k])[3]-MFMaximo[k]>0
                    push!(NewAlcanzables,(MatrizFlujo[k])[2])
                end
            end
        end
        X_in= get(EntradaFlujo,z,[])
        if !isempty(X_in)
            for k in X_in
                if MFMaximo[k]>0
                    push!(NewAlcanzables,(MatrizFlujo[k])[1])
                end
            end
        end
    end
    Alcanzables =  union(Alcanzables, NewAlcanzables)
    tmAlc=length(Alcanzables)
end
Cortadura=Set()
for z in Alcanzables
    X_out = get(SalidaFlujo,z,[])
    if !isempty(X_out)
        for k in X_out
            if !in((MatrizFlujo[k])[2], Alcanzables)
                push!(Cortadura,z)
            end
        end
    end
end

ImgFinaBorder = zeros(m,n);
for i=1:m
    for j=1:n
        I = (i-1)*n+j
        if  in(I,Cortadura)
            ImgFinaBorder[i,j]=1.0
        end
    end
end
print("termine2")
imgFinal=colorview(Gray,ImgFinaBorder)
save("ImgPensanteFinal.jpg", imgFinal)
