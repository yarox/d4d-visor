# -*- coding: utf-8 -*-

import glob
import csv
import re

from qgis.core import *
QgsApplication.setPrefixPath("/usr/", True)
QgsApplication.initQgis()


for inpath in glob.glob("/d3/antennas_weight/*.tsv"):
    outpath = inpath.replace('weight', 'weight_corrected')

    with open(inpath, 'r') as fin, open(outpath, 'w') as fout:
        lines = fin.readlines()
        lines[0] = lines[0].replace('antenna_', '')
        fout.writelines(''.join(lines))

max_weight = 0

days_mapping = {d: i for i, d in enumerate('DLMXJVS')}
regex = re.compile(r'([DLMXJVS])_.*_(\d+).tsv')

vlayer = QgsVectorLayer("/d3/layers/ivory.geojson", "ivory", "ogr")

for inpath in glob.glob("/d3/antennas_weight_corrected/*.tsv"):
    day, hour = regex.search(inpath).groups()
    outpath = '/d3/weights/weights{0}_{1}.csv'.format(days_mapping[day], hour)

    print 'processing', inpath

    with open(outpath, 'w') as fout:
        uri = "{0}?delimiter={1}&xField={2}&yField={3}".format(inpath, '\t', 'lon', 'lat')

        dlayer = QgsVectorLayer(uri, "weights", "delimitedtext")
        dlayer.select(dlayer.pendingAllAttributesList())
        vlayer.select(vlayer.pendingAllAttributesList())

        index = QgsSpatialIndex()
        dlayer_features = {}

        for feature in dlayer:
            index.insertFeature(feature)
            dlayer_features[feature.id()] = feature

        writer = csv.writer(fout)
        writer.writerow(('id', 'weight'))

        for feature in vlayer:
            ids = index.intersects(feature.geometry().boundingBox())
            total = sum([dlayer_features[id].attributeMap()[2].toDouble()[0] for id in ids]
            writer.writerow((feature.id(), total)))

            max_weight = max(max_weight, total)

print max_weight

regex = re.compile(r'weights(\d+)_*')
key = lambda name: regex.match(os.path.basename(name)).groups()[0]

files = sorted(glob.glob("/d3/data/weights*.csv"), key=key)
groups = itertools.groupby(files, key)

frames = {}

for group, data in groups:
    series = [pandas.Series.from_csv(filename, header=0, index_col=0) for filename in data]
    frames[group] = pandas.concat(series, join='outer', axis=1)

panel = pandas.Panel(frames)
total_weight = panel.sum()
total_weight.to_csv('/d3/data/total_weights.csv', header=True, index=True, index_label='hour')

total_weight.transpose().to_csv('/d3/data/total_weights.csv', header=True, index=False)
