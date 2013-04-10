# encoding: utf-8

#
# This is a simple game world simulating a bunch of spheres looking
# like atomic particles colliding with each other. When the game loop begins
# the user will notice random spheres (atomic particles) floating and
# colliding. The user is able to press a button to generate more
# atomic particles. Also, the user can freeze the game.
#
# @author cdea
#

class AtomSmasher
  include GameWorld
  java_import javafx.scene.paint.Color
  java_import javafx.application.Platform
  java_import javafx.scene.control.ButtonBuilder
  java_import javafx.scene.layout.HBoxBuilder
  java_import javafx.scene.layout.VBoxBuilder
  java_import javafx.scene.Group
  java_import javafx.scene.Scene
  java_import javafx.scene.control.Label

  def initialize fps, title
    super
    @num_sprites_field = Label.new
  end
  #
  # Initialize the game world by adding sprite objects.
  # @param primaryStage
  #
  def init primaryStage
    # Sets the window title
    primaryStage.setTitle getWindowTitle

    # Create the scene
    setSceneNodes Group.new
    setGameSurface Scene.new getSceneNodes, 640, 580
    primaryStage.setScene getGameSurface

    generateManySpheres 150

    # Display the number of spheres visible.
    # Create a button to add more spheres.
    # Create a button to freeze the game loop.
    gameLoop = getGameLoop
    stats = VBoxBuilder.create
      .spacing(5)
      .translateX(10)
      .translateY(10)
      .children(HBoxBuilder.create
        .spacing(5)
        .children(
          Label.new("Number of Particles: "),
          @num_sprites_field
        ).build,

          # button to build more spheres
          ButtonBuilder.create
            .text("Regenerate")
            .onMousePressed(proc {
                generateManySpheres 150
            }).build,

          # button to freeze game loop
          ButtonBuilder.create
            .text("Freeze/Resume")
            .onMousePressed(proc {
              case gameLoop.getStatus
                when Animation::Status::RUNNING
                  gameLoop.stop
                when Animation::Status::STOPPED
                  gameLoop.play
              end
            }).build
      ).build # (VBox) stats on children

    # lay down the controls
    getSceneNodes.getChildren.add stats
  end


  #
  # Make some more space spheres (Atomic particles)
  #
  def generateManySpheres numSpheres
    rnd = java.util.Random.new
    gameSurface = getGameSurface

    bubbles = []
    numSpheres.times do
      c = Color.rgb rnd.nextInt(255), rnd.nextInt(255), rnd.nextInt(255)
      b = Atom.new rnd.nextInt(15) + 5, c
      circle = b.getAsCircle
      # random 0 to 2 + (.0 to 1) * random (1 or -1)
      b.vX = (rnd.nextInt(2) + rnd.nextDouble) * (rnd.nextBoolean ? 1 : -1)
      b.vY = (rnd.nextInt(2) + rnd.nextDouble) * (rnd.nextBoolean ? 1 : -1)

      # random x between 0 to width of scene
      newX = rnd.nextInt gameSurface.getWidth

      # check for the right of the width newX is greater than width
      # minus radius times 2(width of sprite)
      if newX > gameSurface.get_width - (circle.getRadius * 2)
        newX = gameSurface.get_width - (circle.getRadius  * 2)
      end

      # check for the bottom of screen the height newY is greater than height
      # minus radius times 2(height of sprite)
      newY = rnd.nextInt gameSurface.get_height
      if newY > gameSurface.get_height - (circle.getRadius * 2)
        newY = gameSurface.get_height - (circle.getRadius * 2)
      end

      circle.setTranslateX newX
      circle.setTranslateY newY
      circle.setVisible true
      circle.set_id "atom-#{b.object_id}"

      # add to actors in play (sprite objects)
      getSpriteManager.addSprites b

      # add sprites
      getSceneNodes.getChildren.add 0, b.node
    end
  end
  private :generateManySpheres

  #
  # Each sprite will update it's velocity and bounce off wall borders.
  # @param sprite - An atomic particle (a sphere).
  #
  def handleUpdate sprite

    if sprite.is_a? Atom
      sphere = sprite.node

      #advance the spheres velocity
      sprite.update

      # bounce off the walls when outside of boundaries
      sprite.vX *= -1 if sphere.getTranslateX > getGameSurface.getWidth - sphere.getBoundsInParent.getWidth or
         sphere.getTranslateX < 0
      sprite.vY *= -1 if sphere.getTranslateY > getGameSurface.getHeight - sphere.getBoundsInParent.getHeight or
         sphere.getTranslateY < 0
    end
  end

  #
  # How to handle the collision of two sprite objects. Stops the particle
  # by zeroing out the velocity if a collision occurred.
  # @param spriteA
  # @param spriteB
  # @return
  #
  def handleCollision spriteA, spriteB
    if spriteA.collide spriteB
      spriteA.implode self
      spriteB.implode self
      getSpriteManager.addSpritesToBeRemoved spriteA, spriteB
      true
    end
  end

  #
  # Remove dead things.
  #
  def cleanupSprites
    # removes from the scene and backend store
    super
    # let user know how many sprites are showing.
    size = getSpriteManager.getAllSprites.size
    @num_sprites_field.setText "#{size}"
    if size == 0
      @gameLoop.stop
      Platform.exit
    end
  end

end
