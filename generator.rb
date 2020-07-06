require 'json'
require 'optparse'

# TODO: throw error on invalid schemas

# Documents the JSON schema
# returns the documented string
def document(obj, level=1)
    str = "<div style='margin-left:#{5 * (level)}px;'>\n\n"

    # Apply limits to the heading levels
    if level < 1
        level = 1
    elsif level > 6
        level = 6
    end

    if obj.has_key? "title"
        str += "<h#{level}>#{obj["title"]}</h#{level}>\n"
    end

    if obj.has_key? "description"
        str += "<p>#{obj["description"]}</p>\n"
    end

    if obj.has_key? "type"
        str += "<p>type: <code>#{obj["type"]}</code></p>"
    end

    case obj['type']
    when 'string'
        str += "<p>Restrictions:</p>\n<ul>\n"
        noRestrictions = true

        # Length restrictions
        if obj.has_key? 'minLength' and obj.has_key? 'maxLength'
            str += "<li>Must be longer than #{obj['minLength']} characters and shorter than #{obj['maxLength']} characters</li>\n"
            noRestrictions = false
        elsif obj.has_key? 'minLength'
            str += "<li>Must be longer than #{obj['minLength']} characters</li>\n"
            noRestrictions = false
        elsif obj.has_key? 'maxLength'
            str += "<li>Must be shorter than #{obj['maxLength']} characters</li>\n"
            noRestrictions = false
        end

        # Regular expressions
        if obj.has_key? 'pattern'
            str += "<li>Must match the regular expression <code>/#{obj['pattern']}/</code></li>\n"
            noRestrictions = false
        end

        # Formats
        # TODO: consider allowing custom format (more json parsing?)
        # TODO: add examples of the formats because nobody reads standards
        if obj.has_key? 'format'
            case obj['format']
            when 'date-time'
                str += "<li>Must be an ISO-8601 formatted date and time (<code>YYYY-MM-DDThh:mm:ss+hh:mm</code>)</li>\n"
            when 'time'
                str += "<li>Must be an ISO-8601 formatted time (<code>hh:mm:ss+hh:mm</code>)</li>\n"
            when 'date'
                str += "<li>Must be an ISO-8601 formatted date (<code>YYYY-MM-DD</code>)</li>\n"
            when 'email'
                str += "<li>Must be an email address compliant with <a href='https://tools.ietf.org/html/rfc5322#section-3.4.1'>RFC5311&sect;3.4.1</a>'</li>\n"
            when 'idn-email'
                str += "<li>Must be an internationalized email address compliant with <a href='https://tools.ietf.org/html/rfc6531'>RFC6531</a></li>\n"
            when 'hostname'
                str += "<li>Must be an internet host name compliant with <a href='https://tools.ietf.org/html/rfc1034#section-3.1'>RFC1034&sect;3.1</a></li>\n"
            when 'idn-hostname'
                str += "<li>Must be an internationalized internet host name, compliant with <a href='https://tools.ietf.org/html/rfc5890#section-2.3.2.3'>RFC5890&sect;2.3.2.3</a></li>\n"
            when 'ipv4'
                str += "<li>Must be an IPv4 address <a href='https://tools.ietf.org/html/rfc2673#section-3.2'>RFC2673&sect;3.2</a></li>\n"
            when 'ipv6'
                str += "<li>Must be an IPv6 address (<a href='https://tools.ietf.org/html/rfc2373#section-2.2'>RFC2373&sect;2.2</a>)</li>\n"
            when 'uri'
                str += "<li>Must be an <a href='https://tools.ietf.org/html/rfc3986'>RFC3986</a>-compliant URI</li>\n"
            when 'uri-reference'
                str += "<li>Must be a URI reference according to <a href='https://tools.ietf.org/html/rfc3986#section-4.1'>RFC3986&sect;4.1</a></li>\n"
            when 'iri'
                str += "<li>Must be an <a href='https://tools.ietf.org/html/rfc3987'>RFC3987</a>-compliant internationalized URI</li>\n"
            when 'iri-reference'
                str += "<li>Must be an <a href='https://tools.ietf.org/html/rfc3987'>RFC3987</a>-compliant internationalized URI reference</li>\n"
            when 'uri-template'
                str += "<li>Must be an <a href='https://tools.ietf.org/html/rfc6570'>RFC6570</a>-compliant URI template</li>\n"
            when 'json-pointer'
                str += "<li>Must be a JSON pointer as specified in <a href='https://tools.ietf.org/html/rfc6901'>RFC6901</a></li>\n"
            when 'relative-json-pointer'
                str += "<li>Must be a <a href='https://tools.ietf.org/html/draft-handrews-relative-json-pointer-01'>relative JSON pointer</a></li>\n"
            when 'regex'
                str += "<li>Must be a regular expression, following the <a href='https://www.ecma-international.org/publications/files/ECMA-ST/Ecma-262.pdf'>ECMA 262</a> dialect</li>\n"
            end
            noRestrictions = false
        end

        if noRestrictions
            # TODO: just don't put anything in in this case
            str += "<li>None</li>\n"
        end
    when 'integer'
        # idk what actual restrictions can be placed on this; ill check the actual specification later
    when 'number'
        str += "<p>Restrictions:</p>\n<ul>\n"
        noRestrictions = true

        if obj.has_key? 'multipleOf'
            str += "<li>Number must be a multiple of #{obj['multipleOf']}</li>\n"
            noRestrictions = false
        end

        if obj.has_key? 'minimum' or obj.has_key? 'maximum' or obj.has_key? 'exclusiveMinimum' or obj.has_key? 'exclusiveMaximum'
            range = "<li>Number must be"

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

            str += range + "</li>\n"
            noRestrictions = false
        end

        if noRestrictions
            # TODO: just don't put anything in in this case
            str += "<li>None</li>\n"
        end
        
        str += "</ul>\n"
    when 'object'
        if obj.has_key? 'properties'
            obj['properties'].each do |key, value|
                str += "\n<b><code>#{key}</code>:</b>\n#{document(value, level+1)}"

                if obj.has_key? 'required'
                    if obj['required'].include? key
                        str += "\nThis property is required\n"
                    end
                end

                if obj.has_key? 'dependencies'
                    # TODO: add support for schema dependencies
                    if obj['dependencies'].has_key? key and obj['dependencies'][key].instance_of? Array
                        if obj['dependencies'][key].length == 1
                            str += "\n<code>#{key}</code> requires <code>#{obj['dependencies'][key][0]}</code> to be present\n"
                        else
                            str += "\n<code>#{key}</code> requires the properties <code>#{obj['dependencies'][key].join('</code>, <code>')}</code> to be present.\n"
                        end
                    end
                end
            end
        end

        if obj.has_key? 'additionalProperties'
            if obj['additionalProperties'] == false
                str += "\nNo additional properties are permitted"
            else
                str += "\n<b>Additional properties:<b>\n#{document(obj['additionalProperties'], level+1)}"
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
                str += "\nAdditional properties whose names match <code>#{key}</code>:\n#{document(value, level+1)}"
            end
        end

        # Length restrictions
        if obj.has_key? 'minProperties' and obj.has_key? 'maxProperties'
            str += "<p>Must have at least #{obj['minProperties']} properties and no more than #{obj['maxProperties']} properties</p>\n"
            noRestrictions = false
        elsif obj.has_key? 'minProperties'
            str += "<p>Must have at least #{obj['minProperties']} properties</p>\n"
            noRestrictions = false
        elsif obj.has_key? 'maxProperties'
            str += "<p>Must have no more than #{obj['maxProperties']} properties</p>\n"
            noRestrictions = false
        end
    when 'array'
        # Length restrictions
        if obj.has_key? 'minLength' and obj.has_key? 'maxLength'
            str += "<p>Must be longer than #{obj['minLength']} items and shorter than #{obj['maxLength']} items</p>\n"
            noRestrictions = false
        elsif obj.has_key? 'minLength'
            str += "<p>Must be longer than #{obj['minLength']} items</p>\n"
            noRestrictions = false
        elsif obj.has_key? 'maxLength'
            str += "<p>Must be shorter than #{obj['maxLength']} items</p>\n"
            noRestrictions = false
        end

        if obj.has_key? 'uniqueItems'
            if obj['uniqueItems']
                str += "<p>All items must be unique</p>\n"
            end
        end

        if obj.has_key? 'items'
            if obj['items'].instance_of? Hash
                # This is an array
                str += "\n<b>Elements:</b>\n#{document(obj['items'], level+1)}"
            elsif obj['items'].instance_of? Array
                # This is a tuple
                obj['items'].each_with_index do |item, index|
                    str += "\n<b>Element #{index}:</b>\n#{document(item, level+1)}"
                end

                if obj.has_key? 'additionalItems'
                    if obj['additionalItems'] == false
                        str += "\nNo additional items are permitted"
                    else
                        str += "\n<b>Additional items:</b>\n#{document(obj['additionalItems'], level+1)}"
                    end
                end
            end
        end

        str += "</ul>"
    when 'boolean'
        # Nothing to do in this case
    when 'null'
        # Nothing to do in this case
    end

    # Default value
    if obj.has_key? 'default'
        str += "\nDefault: <code>#{obj['default']}</code>\n"
    end

    # Handle examples
    if obj.has_key? 'examples'
        str += "<p>Examples:</p>\n<ul>\n"
        obj['examples'].each do |example|
            str += "<li><code>#{example}</code></li>\n"
        end
        str += "</ul>"
    end

    return str + "\n</div>\n"
end

args = {}
OptionParser.new do |opts|
    opts.banner = 'Usage: generator.rb [options]'

    opts.on('-i', '--input FILE', 'The input JSON schema to generate documentation from') do |file|
        args[:input] = file
    end

    opts.on('-o', '--output file', 'The the file to place the generated HTML into') do |file|
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

title = args[:input]
if data.has_key? "title"
    title = data["title"]
end

# Generate html file

outFile.puts %Q(
<!DOCTYPE html>
<html>
<head>
<title>#{title}</title>
<style>
div {
    border-left: #AAAAAA 2px solid;
    padding-left: 7px;
}
code {
    background-color: #CCCCCC;
    border-radius: 2px;
    padding: 2px;
}
li {
    list-style-type: '\\2013  ';
}
</style>
</head>
<body>
#{document(data)}
</body>
</html>
)
