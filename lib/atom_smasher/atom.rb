# encoding: utf-8

# A spherical looking object (Atom) with a random radius, color, and velocity.
# When two atoms collide each will fade and become removed from the scene. The
# method called implode() implements a fade transition effect.
#
# ported to jRuby with JavaFX by whitehat101
#
# @author cdea

class Atom
  include Sprite
  java_import javafx.scene.paint.Stop
  java_import javafx.scene.paint.Color
  java_import javafx.animation.FadeTransitionBuilder
  java_import javafx.scene.paint.RadialGradientBuilder
  java_import javafx.scene.shape.CircleBuilder
  java_import javafx.util.Duration

  def initialize radius, fill
    # set javafx node to a circle
    @node = CircleBuilder.create.
      centerX(radius).
      centerY(radius).
      radius(radius).
      cache(true).
      build

    rgrad = RadialGradientBuilder.create
      .centerX(@node.getCenterX - @node.getRadius / 3)
      .centerY(@node.getCenterY - @node.getRadius / 3)
      .radius(@node.getRadius)
      .proportional(false)
      .stops(Stop.new(0.0, fill), Stop.new(1.0, Color::BLACK))
      .build

    @node.setFill rgrad
  end

  #
  # Change the velocity of the atom particle.
  #
  # @Override
  # public void
  def update
    @node.setTranslateX @node.getTranslateX + @vX
    @node.setTranslateY @node.getTranslateY + @vY
  end

  def collide other
    if other.is_a? Atom
      atom_collide(other) unless other == self
    end
  end

  #
  # When encountering another Atom to determine if they collided.
  # @param other Another atom
  # @return boolean true if this atom and other atom has collided,
  # otherwise false.
  #
  def atom_collide other

    # if an object is hidden they didn't collide.
    if !@node.isVisible or !other.node.isVisible or self == other
      return false
    end

    # determine its size
    otherSphere = other.getAsCircle
    thisSphere  = getAsCircle
    dx          = otherSphere.getTranslateX - thisSphere.getTranslateX
    dy          = otherSphere.getTranslateY - thisSphere.getTranslateY
    distance    = Math.sqrt dx*dx + dy*dy
    minDist     = otherSphere.get_radius + thisSphere.get_radius + 3

    distance < minDist
  end
  private :atom_collide

  #
  # Returns a node casted as a JavaFX Circle shape.
  # @return Circle shape representing JavaFX node for convenience.
  #
  def getAsCircle
    @node
  end

  #
  # Animate an implosion. Once done remove from the game world
  # @param gameWorld - game world
  #
  def implode gameWorld
    @vX = @vY = 0
    FadeTransitionBuilder.create
    .node(@node)
    .duration(Duration.millis 300)
    .fromValue(@node.getOpacity)
    .toValue(0)
    .onFinished(proc do
      @isDead = true
      gameWorld.getSceneNodes.getChildren.remove @node
    end)
    .build
    .play
  end
end
