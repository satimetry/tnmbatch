
library("grid")
library("png")
library("mailR")

img <- readPNG("~/Dropbox/4CastR2/4CastR.png")
g <- rasterGrob(img, interpolate=TRUE)

body <- paste("Body of the email", img, sep="")

send.mail(from = "StefanoPicozzi@gmail.com",
          to = "StefanoPicozzi@gmail.com",
          subject = "Subject of the email",
          body = body,
          smtp = list(host.name = "smtp.gmail.com", port = 465, 
                      user.name = "StefanoPicozzi", passwd = "*******", ssl = TRUE),
          authenticate = TRUE,
          send = TRUE)



