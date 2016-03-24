var spinalCore = require('../lib/spinalcore.node');

describe('The SpinalCore API', function() {

    // TODO: The test suite cases should be per method

    it('should extend a JavaScript object', function() {
        function TestModel() {
            TestModel.super(this);
        }

        spinalCore.extend(TestModel, Model);

        sampleModel = new TestModel();

        expect(typeof sampleModel.add_attr).toBe("function");
    });

    describe('The FileSystem interaction', function () {
        var conn;

        beforeAll(function () {
            conn = spinalCore.connect("http://user@host:8888/dir");

            spyOn(conn, 'load_or_make_dir');
        });

        it('should return a FileSystem instance', function() {
          expect(conn).toEqual(jasmine.any(FileSystem));
        });

        it('should store a model in the FileSystem', function() {

            var modelSample = new Str("some text");
            spinalCore.store(conn, modelSample, "test", function () {});

            expect(conn.load_or_make_dir).toHaveBeenCalled();
        });

        it('should load a model from the FileSystem', function() {
            spinalCore.sync(conn, "test", function () {});

            expect(conn.load_or_make_dir).toHaveBeenCalled();
        });

    });

});
