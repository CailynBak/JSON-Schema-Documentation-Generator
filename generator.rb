require 'json'
require 'optparse'

# TODO: throw error on invalid schemas
# TODO: make formatting better and more intuitive

# Documents the JSON schema
# returns the documented string
def document(obj, level=1)
    str = "<div style='margin-left:#{10 * (level-1)}'>\n\n"

    # Apply limits to the heading levels
    if level < 1
        level = 1
    elsif level > 6
        level = 6
    end

    if obj.has_key? "title"
        str += "#{'#' * level} #{obj["title"]}\n"
    end

    if obj.has_key? "description"
        str += "\n#{obj["description"]}\n"
    end

    if obj.has_key? "type"
        str += "\ntype: `#{obj["type"]}`\n"
    end

    case obj['type']
    when 'string'
        str += "\nRestrictions:\n"
        noRestrictions = true

        # Length restrictions
        if obj.has_key? 'minLength' and obj.has_key? 'maxLength'
            str += "- Must be longer than #{obj['minLength']} characters and shorter than #{obj['maxLength']} characters\n"
            noRestrictions = false
        elsif obj.has_key? 'minLength'
            str += "- Must be longer than #{obj['minLength']} characters\n"
            noRestrictions = false
        elsif obj.has_key? 'maxLength'
            str += "- Must be shorter than #{obj['maxLength']} characters\n"
            noRestrictions = false
        end

        # Regular expressions
        if obj.has_key? 'pattern'
            str += "- Must match the regular expression `/#{obj['pattern']}/`\n"
            noRestrictions = false
        end

        # Formats
        # TODO: consider allowing custom format (more json parsing?)
        if obj.has_key? 'format'
            case obj['format']
            when 'date-time'
                str += "- Must be an ISO-8601 formatted date and time (`YYYY-MM-DDThh:mm:ss+hh:mm`)\n"
            when 'time'
                str += "- Must be an ISO-8601 formatted time (`hh:mm:ss+hh:mm`)\n"
            when 'date'
                str += "- Must be an ISO-8601 formatted date (`YYYY-MM-DD`)\n"
            when 'email'
                str += "- Must be an email address compliant with [RFC5311&sect;3.4.1](https://tools.ietf.org/html/rfc5322#section-3.4.1)\n"
            when 'idn-email'
                str += "- Must be an internationalized email address compliant with [RFC6531](https://tools.ietf.org/html/rfc6531)\n"
            when 'hostname'
                str += "- Must be an internet host name compliant with [RFC1034&sect;3.1](https://tools.ietf.org/html/rfc1034#section-3.1)\n"
            when 'idn-hostname'
                str += "- Must be an internationalized internet host name, compliant with [RFC5890&sect;2.3.2.3](https://tools.ietf.org/html/rfc5890#section-2.3.2.3)\n"
            when 'ipv4'
                str += "- Must be an IPv4 address ([RFC2673&sect;3.2](https://tools.ietf.org/html/rfc2673#section-3.2))\n"
            when 'ipv6'
                str += "- Must be an IPv6 address ([RFC2373&sect;2.2](https://tools.ietf.org/html/rfc2373#section-2.2))\n"
            when 'uri'
                str += "- Must be an [RFC3986](https://tools.ietf.org/html/rfc3986)-compliant URI\n"
            when 'uri-reference'
                str += "- Must be a URI reference according to [RFC3986&sect;4.1](https://tools.ietf.org/html/rfc3986#section-4.1)\n"
            when 'iri'
                str += "- Must be an [RFC3987](https://tools.ietf.org/html/rfc3987)-compliant internationalized URI\n"
            when 'iri-reference'
                str += "- Must be an [RFC3987](https://tools.ietf.org/html/rfc3987)-compliant internationalized URI reference\n"
            when 'uri-template'
                str += "- Must be an [RFC6570](https://tools.ietf.org/html/rfc6570)-compliant URI template\n"
            when 'json-pointer'
                str += "- Must be a JSON pointer as specified in [RFC6901](https://tools.ietf.org/html/rfc6901)\n"
            when 'relative-json-pointer'
                str += "- Must be a [relative JSON pointer](https://tools.ietf.org/html/draft-handrews-relative-json-pointer-01)\n"
            when 'regex'
                str += "- Must be a regular expression, following the [ECMA 262](https://www.ecma-international.org/publications/files/ECMA-ST/Ecma-262.pdf) dialect\n"
            end
            noRestrictions = false
        end

        if noRestrictions
            str += "- None\n"
        end
    when 'integer'
        # idk what actual restrictions can be placed on this; ill check the actual specification later
    when 'number'
        str += "\nRestrictions:\n"
        noRestrictions = true

        if obj.has_key? 'multipleOf'
            str += "- Number must be a multiple of #{obj['multipleOf']}\n"
            noRestrictions = false
        end

        if obj.has_key? 'minimum' or obj.has_key? 'maximum' or obj.has_key? 'exclusiveMinimum' or obj.has_key? 'exclusiveMaximum'
            range = "- Number must be"

            if obj.has_key? 'minimum'
                range += " greater than or equal to #{obj['minimum']}"

                if obj.has_key? 'maximum' or obj.has_key? 'exclusiveMaximum'
                    range += ' and'
                end
            elsif obj.has_key? 'exclusiveMinimum'
                range += " greater than #{obj['exclusiveMinimum']}"

                if obj.has_key? 'maximum' or obj.has_key? 'exclusiveMaximum'
                    range += ' and'
                end
            end

            if obj.has_key? 'maximum'
                range += " less than or equal to #{obj['maximum']}"
            elsif obj.has_key? 'exclusiveMaximum'
                range += " less than #{obj['exclusiveMaximum']}"
            end

            str += range + "\n"
            noRestrictions = false
        end

        if noRestrictions
            str += "- None\n"
        end
    when 'object'

        if obj.has_key? 'properties'
            obj['properties'].each do |key, value|
                str += "\n**#{key}:**\n#{document(value, level+1)}"

                if obj.has_key? 'required'
                    if obj['required'].include? key
                        str += "\nThis property is required\n"
                    end
                end

                if obj.has_key? 'dependencies'
                    # TODO: add support for schema dependencies
                    if obj['dependencies'].has_key? key and obj['dependencies'][key].instance_of? Array
                        if obj['dependencies'][key].length == 1
                            str += "\n`#{key}` requires `#{obj['dependencies'][key][0]}` to be present\n"
                        else
                            str += "\n`#{key}` requires the properties `#{obj['dependencies'][key].join('`, `')}` to be present.\n"
                        end
                    end
                end
            end
        end

        if obj.has_key? 'additionalProperties'
            if obj['additionalProperties'] == false
                str += "\nNo additional properties are permitted"
            else
                str += "\n**Additional properties:**\n#{document(obj['additionalProperties'], level+1)}"
            end
        end

        if obj.has_key? 'propertyNames'
            if obj['propertyNames'].has_key? 'type'
                if obj['propertyNames']['type'] != 'string'
                    # haha unclear error messages go brrr
                    STDERR.puts "Property names must be strings."
                    exit
                end
            else
                obj['propertyNames']['type'] = 'string'
            end

            str += "\nAll property names must match the following schema:\n#{document(obj['propertyNames'], level+1)}"
        end

        # Pattern Properties
        if obj.has_key? 'patternProperties'
            obj['patternProperties'].each do |key, value|
                str += "\nAdditional properties whose names match `#{key}`:\n#{document(value, level+1)}"
            end
        end

        # Length restrictions
        if obj.has_key? 'minProperties' and obj.has_key? 'maxProperties'
            str += "- Must have at least #{obj['minProperties']} properties and no more than #{obj['maxProperties']} properties\n"
            noRestrictions = false
        elsif obj.has_key? 'minProperties'
            str += "- Must have at least #{obj['minProperties']} properties\n"
            noRestrictions = false
        elsif obj.has_key? 'maxProperties'
            str += "- Must have no more than #{obj['maxProperties']} properties\n"
            noRestrictions = false
        end

    when 'array'
        # Length restrictions
        if obj.has_key? 'minLength' and obj.has_key? 'maxLength'
            str += "- Must be longer than #{obj['minLength']} items and shorter than #{obj['maxLength']} items\n"
            noRestrictions = false
        elsif obj.has_key? 'minLength'
            str += "- Must be longer than #{obj['minLength']} items\n"
            noRestrictions = false
        elsif obj.has_key? 'maxLength'
            str += "- Must be shorter than #{obj['maxLength']} items\n"
            noRestrictions = false
        end

        if obj.has_key? 'uniqueItems'
            if obj['uniqueItems']
                str += "\nAll items must be unique\n"
            end
        end

        if obj.has_key? 'items'
            if obj['items'].instance_of? Hash
                # This is an array
                str += "\n**Elements:**\n#{document(obj['items'], level+1)}"
            elsif obj['items'].instance_of? Array
                # This is a tuple
                obj['items'].each_with_index do |item, index|
                    str += "\n**Element #{index}:**\n#{document(item, level+1)}"
                end

                if obj.has_key? 'additionalItems'
                    if obj['additionalItems'] == false
                        str += "\nNo additional items are permitted"
                    else
                        str += "\n**Additional items:**\n#{document(obj['additionalItems'], level+1)}"
                    end
                end
            end
        end
    when 'boolean'
        # Nothing to do in this case
    when 'null'
        # Nothing to do in this case
    end

    return str + "\n</div>"
end

args = {}
OptionParser.new do |opts|
    opts.banner = 'Usage: generator.rb [options]'

    opts.on('-i', '--input FILE', 'The input JSON schema to generate documentation from') do |file|
        args[:input] = file
    end

    opts.on('-o', '--output file', 'The the file to place the generated markdown into') do |file|
        args[:output] = file
    end

    opts.on('-h', '--help', 'Print the help message') do
        puts opts
        exit
    end
end.parse!(into: args)

# Get schema
inFile = File.open(args[:input], 'r')
outFile = File.open(args[:output], 'w')
data = JSON.load inFile
inFile.close

# Generate markdown file
outFile.puts document(data)
