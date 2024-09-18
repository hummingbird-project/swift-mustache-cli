import Testing

@testable import MustacheCLI

struct MustacheCLITests {
    @Test("Test string")
    func testString() throws {
        let template = "{{test}}"
        let context = """
        test: hello
        """
        let result = try MustacheApp.Renderer().render(template: template, contexts: [context])
        #expect(result == "hello")
    }

    @Test("Test array")
    func testArray() throws {
        let template = "{{#test}}{{.}}{{/test}}"
        let context = """
        test:
          - one
          - two
          - three
        """
        let result = try MustacheApp.Renderer().render(template: template, contexts: [context])
        #expect(result == "onetwothree")
    }

    @Test("Test dictionary")
    func testDictionary() throws {
        let template = "{{test.inner}}"
        let context = """
        test:
          inner: "Inner"
        """
        let result = try MustacheApp.Renderer().render(template: template, contexts: [context])
        #expect(result == "Inner")
    }

    @Test("Test multiple levels dictionary")
    func testMultipleLevelsDictionary() throws {
        let template = "{{test.outer.inner}}"
        let context = """
        test:
          outer:
            inner: "Inner"
        """
        let result = try MustacheApp.Renderer().render(template: template, contexts: [context])
        #expect(result == "Inner")
    }

    @Test("Test string override")
    func testStringOverride() throws {
        let template = "{{test}}"
        let context = """
        test: hello
        """
        let context2 = """
        test: goodbye
        """
        let result = try MustacheApp.Renderer().render(template: template, contexts: [context, context2])
        #expect(result == "goodbye")
    }

    @Test("Test inner string override")
    func testInnerStringOverride() throws {
        let template = "{{test.inner}}"
        let context = """
        test:
          inner: hello
        """
        let context2 = """
        test:
          inner: goodbye
        """
        let result = try MustacheApp.Renderer().render(template: template, contexts: [context, context2])
        #expect(result == "goodbye")
    }

    @Test("Test inner not overriden")
    func testInnerNotOverriden() throws {
        let template = "{{test.other}}"
        let context = """
        test:
          inner: hello
          other: test
        """
        let context2 = """
        test:
          inner: goodbye
        """
        let result = try MustacheApp.Renderer().render(template: template, contexts: [context, context2])
        #expect(result == "test")
    }

    @Test("Test array override")
    func testArrayOverride() throws {
        let template = "{{#test}}{{#inner}}{{.}}{{/inner}}{{/test}}"
        let context = """
        test:
          inner: [1,2,3]
        """
        let context2 = """
        test:
          inner: [3,2,1]
        """
        let result = try MustacheApp.Renderer().render(template: template, contexts: [context, context2])
        #expect(result == "321")
    }

    @Test("Test inner not overriden")
    func testDisableDictionary() throws {
        let template = "{{#test}}{{other}}{{/test}}"
        let context = """
        test:
          inner: hello
        """
        let context2 = """
        test: false
        """
        let result = try MustacheApp.Renderer().render(template: template, contexts: [context, context2])
        #expect(result == "")
    }

}