require 'json'
require 'optparse'

# TODO: take this out of a class; its not necessary
# TODO: throw error on invalid schemas
class SchemaDocumenter
    def initialize(data)
        @data = data
    end

    # Documents the JSON schema
    # returns the documented string
    def document
        documentation = ""

        documentation += generateTitleAndDesc(@data, 1)
        documentation += documentTypes(@data)
    end

    # Generates the title and description for an object
    # obj is the json object to be documented
    # level is the heading level (h1-h6) to be used.
    # returns the generated string
    def generateTitleAndDesc(obj, level)
        str = ""
    
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

        return str
    end

    # TODO: Add support for multiple types
    def documentTypes(obj)
        str = ""

        if obj.has_key? "type"
            str += "\ntype: `#{obj["type"]}`\n"
        end

        case obj['type']
        when 'string'
            str += "\nRestrictions:\n"
            # TODO: add none to list if there are no restrictions

            # Length restrictions
            if obj.has_key? 'minLength' and obj.has_key? 'maxLength'
                str += "- Must be longer than #{obj['minLength']} characters and shorter than #{obj['maxLength']} characters\n"
            elsif obj.has_key? 'minLength'
                str += "- Must be longer than #{obj['minLength']} characters\n"
            elsif obj.has_key? 'maxLength'
                str += "- Must be shorter than #{obj['maxLength']} characters\n"
            end

            # Regular expressions
            if obj.has_key? 'pattern'
                str += "- Must match the regular expression `/#{obj['pattern']}/`\n"
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
            end
        when 'integer'
            # idk what actual restrictions can be placed on this; ill check the actual specification later
        when 'number'
            str += "\nRestrictions:\n"
            # TODO: add none to list if there are no restrictions

            if obj.has_key? 'multipleOf'
                str += "- Number must be a multiple of #{obj['multipleOf']}\n"
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
            end
        when 'object'
        when 'array'
        when 'boolean'
            # Nothing to do in this case
        when 'null'
            # Nothing to do in this case
        end

        return str
    end
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

# Generate file header
outFile.puts SchemaDocumenter.new(data).document
