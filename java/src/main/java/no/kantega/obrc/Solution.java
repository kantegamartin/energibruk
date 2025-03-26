/*
 *  Copyright 2023 The original authors
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package no.kantega.obrc;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.*;


public class Solution {
    private static final String FILE = "./measurements.txt";

    public static void main(String[] args) throws Exception
    {
        var file = new File(args.length > 0 ? args[0] : FILE);
        var results = parse(file).toStringArray();
        Arrays.sort(results);
        System.out.println(String.join("\n", results));
    }

    private static StationList parse(File file) throws Exception {
        StationList stationList = new StationList();
        Files.lines(Paths.get(file.getAbsolutePath()))
                .map(l -> new Station(l.split(";")))
                .forEach(stationList::add);
        return stationList;
    }

    private static final class Station {
        private final String name;
        private double min;
        private double max;
        private double total;
        private double count;

        public Station(String[] parts)
        {
            name = parts[0];
            min = max = total = Double.parseDouble(parts[1]);
            count = 1;
        }

        @Override
        public String toString() {
            return name + "=" + min + "/" + Math.round(10.0 * total / count) / 10.0 + "/" + max;
        }

        private void append(double min, double max, double total, double count) {
            if (min < this.min)
                this.min = min;
            if (max > this.max)
                this.max = max;
            this.total += total;
            this.count += count;
        }

        public void merge(Station other) {
            append(other.min, other.max, other.total, other.count);
        }
    }

    private static class StationList implements Iterable<Station> {
        private final Map<String, Station> array = new HashMap<>();

        public void add(Station station) {
            var existing = array.get(station.name);
            if (existing == null) {
                array.put(station.name, station);
            } else {
                existing.merge(station);
            }
        }

        public String[] toStringArray() {
            var destination = new String[array.size()];

            var i = 0;
            for (Station station : this)
                destination[i++] = station.toString();

            return destination;
        }

        @Override
        public Iterator<Station> iterator() {
            return array.values().iterator();
        }
    }
}
