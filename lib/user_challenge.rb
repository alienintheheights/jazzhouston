# UserChallenge provides several mechanisms to aid in establishing a real user is on the end of a submit

# Typically used for user registration processes or commenting, the UserChallenge module will allow you to provide

# a challenge question and validate the repsponse.

# Mixins include

#       * SumChallenge - provides a simple arimethetic sum to be solved

#       * RandomTextChallenge - supplies a random string of characters

# Supporting Classes include

#       * SumTextChallenger - Class that will provide a question as a text string

#       * SumImageChallenger - Class that will create a png image with the sum in it

#       * RandomTextChallenger - Class that will provide a random text string

#       * RandomTextImageChallenger - Class that will create a png image with the random text string in it

module UserChallenge

    

    # This module creates a challenge that is a basic sum, expecting the respose to be the sums result, e.g. 2+6

    module SumChallenge

        #Initailizes the challenge to a sum

        #optionally specify the max values for the left and right 

        def createChallenge(lMax=10, rMax=10)

            lValue = rand(lMax)

            rValue = rand(rMax)

            @solution = lValue + rValue

            @question = "#{lValue} + #{rValue}"

        end

        # checks the value passed in against the expected result    

        def checkResponse(value)

            return (@solution == value.to_i)

        end

    end

    # This module creates a challenge that is a series of random characters in a specified range, expecting the respose to be the same string

    module RandomTextChallenge

        #Initailizes the challenge to a sum

        #optionally specify the number of characters to generate and the range of characters to choose from

        def createChallenge(count=6, chars = 'a'..'z')

            @question = ""

            count.times do

                index = rand(chars.entries.length-1)

                @question += chars.entries[index]

            end

            @solution = @question

        end

        # checks the value passed in against the expected result    

        def checkResponse(value)

            return (@solution == value.to_s)

        end

    end

    

    # A simple class that generates a sum challenge in text form

    class SumTextChallenger

        include SumChallenge

        

        # the sum question as a string

        attr_reader :question

        # the solution as an integer

        attr_reader :solution

        

        def initialize()

            createChallenge()

        end

    end

    

    # A class that generates a sum challenge in image form

    class SumImageChallenger

        require "RMagick"

        include SumChallenge

        # the sum question as a string

        attr_reader :question

        # the solution as an integer

        attr_reader :solution

        

        def initialize()

            createChallenge()

        end

        

        # returns an image blob with the sum question layered ontop of the specified background

        def render(backgroundImageUrl)

            background = Magick::Image.read(backgroundImageUrl).first

                

            croppedImg = background.crop(0,0,128,28)

            

            text = Magick::Draw.new

            text.annotate(croppedImg, 128, 28, 0, 0, @question) {

              self.gravity = Magick::SouthGravity

              self.pointsize = 24

              self.stroke = 'transparent'

              self.fill = '#0000A9'

              self.font_weight = Magick::BoldWeight

            }

            

            croppedImg = croppedImg.blur_image

            return croppedImg.to_blob

        end

    end

    # A simple class that generates a random text challenge in text form

    class RandomTextChallenger

        include RandomTextChallenge

        

        # the sum question as a string

        attr_reader :question

        # the solution as an integer

        attr_reader :solution

        

        def initialize()

            createChallenge()

        end

    end

    

    # A class that generates a random text challenge in image form

    class RandomTextImageChallenger

        require "RMagick"

        include RandomTextChallenge

        # the sum question as a string

        attr_reader :question

        # the solution as an integer

        attr_reader :solution

        

        def initialize()

            createChallenge()

        end

        

        # returns an image blob with the sum question layered ontop of the specified background

        def render(backgroundImageUrl, width=128)

            background = Magick::Image.read(backgroundImageUrl).first

            

            croppedImg = background.crop(0,0,width,28)

            

            text = Magick::Draw.new

            text.annotate(croppedImg, width, 28, 0, 0, @question) {

              self.gravity = Magick::SouthGravity

              self.pointsize = 22

              self.stroke = 'transparent‘

              self.fill = '#0000A9'

              self.font_weight = Magick::BoldWeight

            }

            

            croppedImg = croppedImg.blur_image

            return croppedImg.to_blob

        end

    end

end


