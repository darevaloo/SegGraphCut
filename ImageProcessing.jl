using Images
using TestImages

###############
#img=testimage("lena")
img = load("pensanteUniandes.jpg")
m , n =size(img)
img2= Gray.(img)

####Seleccionar semillas
img3= load("pensanteSemillas.jpg")
ImgHsv=HSV.(img3)
MaxImag= 100000;




#########
#Función que me calcula la matriz de adyacencia de mi grafo
function GrfImg(grad1,grad2,M=1)
    m, n =size(grad1)
    Adj=[]
    for i in 1:m
        for j in 1:n
            if (i+1<=m)
                #M = maximum([img2[i,j],img2[i+1,j]])
                value = (M-((grad1[i,j]^2+grad2[i,j]^2)^(0.5)+(grad1[i+1,j]^2+grad2[i+1,j]^2)^(0.5))/2)^3
                push!(Adj,[n*(i-1)+j, n*(i)+j, value])
            end
            if (i-1>0)
                #M = maximum([img2[i,j],img2[i-1,j]])
                value = (M-((grad1[i,j]^2+grad2[i,j]^2)^(0.5)+(grad1[i-1,j]^2+grad2[i-1,j]^2)^(0.5))/2)^3
                push!(Adj,[n*(i-1)+j, n*(i-2)+j, value])
            end
            if (j+1<=n)
                #M = maximum([img2[i,j],img2[i,j+1]])
                value = (M-((grad1[i,j]^2+grad2[i,j]^2)^(0.5)+(grad1[i,j+1]^2+grad2[i,j+1]^2)^(0.5))/2)^3
                push!(Adj,[n*(i-1)+j, n*(i-1)+j+1, value])
            end
            if (j-1 > 0)
                #M = maximum([img2[i,j],img2[i,j-1]])
                value = (M-((grad1[i,j]^2+grad2[i,j]^2)^(0.5)+(grad1[i,j-1]^2+grad2[i,j-1]^2)^(0.5))/2)^3
                push!(Adj,[n*(i-1)+j, n*(i-1)+j-1, value])
            end
        end
    end
    return Adj
end





imgg = imfilter(img2, Kernel.gaussian(0))
Gx, Gy=imgradients(imgg);
Gx
Gy
max = 0;
for i in 1:m
    for j in 1:n
        Grad=sqrt(Gx[i,j]^2+Gy[i,j]^2)
        if ( Grad > max   )
            max = Grad
        end
    end
end

MG=GrfImg(Gx,Gy,max)


##mascara para detectar el color rojo
SourceBorder=Set();
for i=1:m
    for j=1:n
        if (ImgHsv[i,j].h <= 15 || ImgHsv[i,j].h >= 340) && ImgHsv[i,j].s>=0.2 && ImgHsv[i,j].v>0.4
            push!(SourceBorder,(i,j))
            push!(MG,[n*(i-1)+j,'t',MaxImag])
        end
    end
end
##mascara para detectar el color azul
TargetBorder=Set()
for i=1:m
    for j=1:n
        if ImgHsv[i,j].h >= 220 && ImgHsv[i,j].h <= 250 && ImgHsv[i,j].s>=0.7 && ImgHsv[i,j].v>0.05
            push!(TargetBorder,(i,j))
            push!(MG,['s',n*(i-1)+j,MaxImag])
        end
    end
end
#img4=colorview(Gray,W)
#intersect(TargetBorder, SourceBorder)
print("termine")
