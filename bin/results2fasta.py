#!/usr/bin/env python
import re
import os
import os.path
import sys

results = sys.argv[1]
output_fasta = sys.argv[2]

with open(results, "r") as input_handle:
    data = input_handle.read()

    id_match = re.search("SEQUENCE_ID=(.+)", data)
    id = id_match.group(1)

    bespoke_regex = "(?P<id>PRIMER_PAIR_[0-9]+)_PENALTY=(?P<penalty>[0-9.]+).+?PRIMER_LEFT_[0-9]+_SEQUENCE=(?P<left>[atcgATCGnN]+).+?PRIMER_RIGHT_[0-9]+_SEQUENCE=(?P<right>[atcgATCGnN]+).+?PRIMER_PAIR_[0-9]+_PRODUCT_SIZE=(?P<size>[0-9]+).+?PRIMER_PAIR_[0-9]+_PRODUCT_TM=[0-9.]+"

    matches = list(re.finditer(bespoke_regex, data, flags=re.MULTILINE | re.DOTALL))

print("Primer3 Results Read")

with open(output_fasta, "w") as output_handle:
    for m in matches:
        line = (
            ">{ID} primer3 {SUBID} penalty:{PEN} type:LEFT product:{PROD}bp".format(
                ID=id, SUBID=m.group("id"), PEN=m.group("penalty"), PROD=m.group("size")
            )
            + os.linesep
        )
        output_handle.write(line)
        line = m.group("left") + os.linesep
        output_handle.write(line)
        line = (
            ">{ID} primer3 {SUBID} penalty:{PEN} type:RIGHT product:{PROD}bp".format(
                ID=id, SUBID=m.group("id"), PEN=m.group("penalty"), PROD=m.group("size")
            )
            + os.linesep
        )
        output_handle.write(line)
        line = m.group("right") + os.linesep
        output_handle.write(line)
        output_handle.close()

print("Fasta file created")
