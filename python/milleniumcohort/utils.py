import ruamel_yaml as yaml
import os

class Config:
    yaml_tag = u'!Config'

    def __init__(self, data_path, hsmmconfig, name=None):
        self.__name = name
        self.hsmmconfig = hsmmconfig
        self.data_path = data_path

    @property
    def name(self):
        if self.__name is None:
            return 'mod_{}st_{}b_{}r_{}t_{}'.format(self.hsmmconfig.Nmax,
                                                     self.hsmmconfig.batch_size,
                                                     self.hsmmconfig.nr_resamples,
                                                     self.hsmmconfig.truncate,
                                                     '_'.join(self.hsmmconfig.column_names))
        else:
            return self.__name


    @property
    def annotations_path(self):
        return os.path.join(self.data_path, 'tud.csv')

    @property
    def wearcodes_path(self):
        return os.path.join(self.data_path, 'wearcodes.csv')

    @property
    def accelerometer_5sec_path(self):
        return os.path.join(self.data_path,
                                                    'accelerometer_5second/')

    @property
    def merged_path(self):
        return os.path.join(self.data_path, 'merged/')

    @property
    def subset_path(self):
        return os.path.join(self.data_path, "subsets/")

    @property
    def results_path(self):
        return os.path.join(self.data_path, 'results')

    @property
    def model_path(self):
        return os.path.join(self.results_path, self.name)

    @property
    def model_file(self):
        return  os.path.join(self.model_path, 'model.pkl')

    @property
    def states_path(self):
        return os.path.join(self.model_path, 'datawithstates')

    @property
    def config_file(self):
        return os.path.join(self.model_path,  'config.py')

    @property
    def image_path(self):
        return os.path.join(self.model_path, 'images')

    @property
    def activities_simplified_path(self):
        return os.path.join(self.data_path,
                                                       'TUD_simplified.csv')


    def create_data_paths(self):
        """
        This function creates all the data paths that are defined in the config
        :return:
        """
        for pathname in [self.merged_path, self.subset_path, self.results_path, self.model_path,
                         self.states_path, self.image_path]:
            if not os.path.exists(pathname):
                os.makedirs(pathname)


    def as_dict(self):
        return {
            'data_path': self.data_path,
            'hsmmconfig': self.hsmmconfig,
            'name': self.name
        }

    def __repr__(self):
        return str(self.as_dict())


def config_constructor(loader, node) :
    fields = loader.construct_mapping(node)
    return Config(**fields)


def config_representer(dumper, data):
    return dumper.represent_mapping(u'!Config', data.as_dict().items())

yaml.add_representer(Config, config_representer)
yaml.add_constructor('!Config', config_constructor)


class HSMMConfig:
    yaml_tag = u'!HSMMConfig'
    def __init__(self, column_names=None, Nmax=4, nr_resamples=20, truncate=720, batch_size=0):
        if column_names is None:
            self.column_names = ['acceleration']
        else:
            self.column_names = column_names
        self.Nmax = Nmax
        self.nr_resamples = nr_resamples
        self.batch_size = batch_size
        self.truncate = truncate

    def as_dict(self):
        return {
            'column_names': self.column_names,
            'Nmax': self.Nmax,
            'nr_resamples': self.nr_resamples,
            'truncate': self.truncate,
            'batch_size': self.batch_size
        }

    def __repr__(self):
        return str(self.as_dict())

def hsmmconfig_constructor(loader, node) :
    fields = loader.construct_mapping(node)
    return HSMMConfig(**fields)


def hsmmconfig_representer(dumper, data):
    return dumper.represent_mapping(u'!HSMMConfig', data.as_dict().items())

yaml.add_representer(HSMMConfig, hsmmconfig_representer)
yaml.add_constructor('!HSMMConfig', hsmmconfig_constructor)


def create_config(configpath):
    with open(configpath) as f:
        conf = yaml.load(f.read())
    return conf
