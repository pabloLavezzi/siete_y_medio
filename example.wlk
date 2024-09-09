/*---- Carta ----- */

class Carta {
  const property numero = 0
  const property palo = ""
  const property tipoCarta

  method descripcion() = numero.toString() + "-" + palo
  method valor() = tipoCarta.valor(self)
}

object cartaComun {
  method valor(carta) = carta.numero() 
}

object cartaFigura {
  method valor(carta) = 0.5
}

/*---- mazo ----- */
object mazo {

  const property cartas = []
  
  method crearCartas(tipoPalo) {
    7.times ({unNumero => cartas.add (new Carta(numero = unNumero  , palo = tipoPalo , tipoCarta = cartaComun))})
    3.times ({unNumero => cartas.add (new Carta(numero = unNumero + 9  , palo = tipoPalo , tipoCarta = cartaFigura))})
  }

  method crearCartas () {
    self.crearCartas("oro")
    self.crearCartas("copa")
    self.crearCartas("basto")
    self.crearCartas("espada")
    cartas.randomize() /* Mezcla el mazo */
  }

  method tomarCarta() {
    /*--- ¿Debería generar una excepción si el mazo no tiene más cartas? ----*/
    const unaCartaDelMazo = cartas.get(0.randomUpTo(cartas.size()-1).roundUp())
    cartas.remove(unaCartaDelMazo)
    return(unaCartaDelMazo)
  }
}


/*---- Jugador ----- */
class Jugador {
  const property cartas = []
  const property nombre = ""

  method recibirCarta (carta) = cartas.add(carta)
  method cartas() = cartas.map({unaCarta => unaCarta.descripcion()})
  method puntaje() {
    if (cartas.size() == 0) return (0)
    return (cartas.sum({unaCarta => unaCarta.valor()}))
  }
  method mensaje (mensaje) = console.println(self.nombre() + " >> " + self.cartas() + " >> Puntaje: " + self.puntaje() + mensaje)
  method mePlanto() = self.puntaje().between(6, 7.5)
  method decisionJugador() {
    if (self.mePlanto()) {
      self.mensaje(" >> Me planto")
    }
    else {
      self.mensaje(" >> Continuo")
    }
  }
}

/*---- Banca ----- */
object banca {
  const property jugadores = []
      
  method registrarJugador(jugador) {
    jugadores.add(jugador)
  }

  method crear_y_BarajarCartas() {
    mazo.crearCartas()
  }

  method entregarCarta() = mazo.tomarCarta()

  method analizarResultado() {
    if (jugadores.size() == 0) {
      console.println("---> No hubo ganadores, todos se excedieron")
    }
    else {
      const puntajeMaximo = (jugadores.max({unJugador => unJugador.puntaje()})).puntaje()
      if (jugadores.count({unJugador => unJugador.puntaje() == puntajeMaximo}) > 1) {
        console.println("---> La partida finalizó empatada por:") 
        jugadores.map({unJugador =>
          if (unJugador.puntaje() == puntajeMaximo) console.println(unJugador.nombre())
         })
      }
      else {
         console.println ("---> Ganador/a:" + (jugadores.max({unJugador => unJugador.puntaje()})).nombre())
      }
    }
   
  }

  method mensajeDeLaBanca (unJugador,mensaje) = console.println(unJugador.nombre() + " >> " + unJugador.cartas() + " >> Puntaje: " + unJugador.puntaje() + mensaje)

  method jugar() {
    console.println("---- Reparto de cartas -----")
    jugadores.map({unJugador =>
        if (not unJugador.mePlanto()) {
          unJugador.recibirCarta(self.entregarCarta())
          if (unJugador.puntaje() > 7.5) {
            self.mensajeDeLaBanca (unJugador," >> Se excedió - jugador Eliminado")
            jugadores.remove(unJugador)
          }
          else {
            unJugador.decisionJugador()
          }
        }
        else {
          unJugador.decisionJugador()
        }
      })
    console.println ("")
    if ((jugadores.size() > 1) and (not jugadores.all({unJugador => unJugador.mePlanto()}))) {
      self.jugar()
    }
    else {
      self.analizarResultado()
    }
  }
  method iniciarJuego() {
    const jugadorBanca = new Jugador(nombre = "Banca")
    self.registrarJugador(jugadorBanca)
    self.jugar()    
  }
}

