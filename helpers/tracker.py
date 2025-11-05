from werkzeug.datastructures import FileStorage

class Tracker:
    _device: str
    _changed_data: dict
    images: list[FileStorage]
    UPLOAD_DIR: str
    separated_data: dict = {
        "create" : [],
        "update" : [],
        "delete" : [],
    }
    
    def __init__(self, changed_data: dict, images: list[FileStorage], upload_dir: str) -> None:
        if len(changed_data['changes']) <= 0:
            self._changed_data = None
        else:
            self._device = changed_data['device']
            self._changed_data = changed_data['changes']
            self._separate()
            self.images = images
            self.UPLOAD_DIR = upload_dir
    
    def _separate(self) -> None:
        for d in self._changed_data:
            if d['type'] in self.separated_data.keys():
                self.separated_data[d['type']].append(d['data'])