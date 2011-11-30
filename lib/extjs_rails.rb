module ExtjsRails

    def to_ext_json(obj)
        tmpArray = [] # array
        # loop over the set of objects
        obj.map do |value|
            tmpArray<<value.attributes
        end
        response = {}  # hash
        response["results"] = tmpArray
        response["items"]=obj.length
        return response.to_json
    end


end
