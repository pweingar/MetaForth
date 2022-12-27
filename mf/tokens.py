import sys

class TokenStream:
    """Class to interpret a text file as a stream of tokens."""

    def __init__(self, file):
        self._file = file
        self._cursor = -1
        self._line = ""
        self._line_number = 0

    def get_line_number(self):
        """Return the current line number."""
        return self._line_number

    def fetch_line(self):
        """Read a line from the file"""
        self._cursor = -1
        self._line = None

        while True:
            line = self._file.readline()
            self._line_number = self._line_number + 1
            if line:
                # Remove any line comments
                comment_index = line.find("\\")
                if comment_index > -1:
                    if comment_index == 0:
                        line = ""
                    else:
                        line = line[0:comment_index]

                # Remove leading and trailing white space
                line = line.strip()

                if len(line) > 0:
                    # We have something... save the line and set the cursor to the start
                    self._line = line
                    self._cursor = 0

                    # And return True
                    return True
            else:
                # We've reached the end of the file
                break

        # We could not read the next line
        return False

    def get_token(self):
        """
        Get the next token from the token stream.

        Return None for end-of-file.
        """

        while True:
            if self._line == "" or self._cursor >= len(self._line):
                # We don't have any saved line... try to fetch a new line
                if not self.fetch_line():
                    # We didn't read anything... return that we have end-of-file
                    return None

            # Skip over any white space
            while self._cursor < len(self._line) and self._line[self._cursor].isspace():
                self._cursor = self._cursor + 1

            if self._cursor < len(self._line):
                # We still have data on the line...
                for i in range(self._cursor, len(self._line)):
                    if self._line[i].isspace():
                        # Found a token get its data and save the new position
                        token = self._line[self._cursor:i]
                        self._cursor = i

                        # Return the token we found
                        return token

                # The token takes the whole line
                token = self._line[self._cursor:]
                self._cursor = len(self._line)
                return token

            else:
                self._line = ""
                self._cursor = -1

    def read_to(self, character):
        """Read the file from the last token to the given character and return the string."""

        data = ""

        if self._line == None or self._cursor >= len(self._line):
            if not self.fetch_line():
                return data

        while self._line:
            index = self._line.find(character, self._cursor)
            if index > -1:
                # Found on the current line... save the data, and we're finished
                data = data + self._line[self._cursor:index]
                self._cursor = index + len(character)
                data = data.strip()
                break

            else:
                # Not found... save what we have of this line and keep trying
                if data == "":
                    data = data + self._line[self._cursor:]
                else:
                    data = data + "\n" + self._line[self._cursor:]
                if not self.fetch_line():
                    # We reached the end of file... just return what we have
                    data = data.strip()
                    break
                
        return data
        
if __name__ == "__main__":
    with open("forth.fth", "r") as input:
        ts = TokenStream(input)
        token = ts.get_token()
        while token:
            if token == "(":
                comment = ts.read_to(")")
                print("Comment: ({})".format(comment))
                #sys.exit(1)
            elif token == "s\"":
                string = ts.read_to("\"")
                print("String: {}".format(string))
            else:
                print("<#token '{}'>".format(token))
            token = ts.get_token()
