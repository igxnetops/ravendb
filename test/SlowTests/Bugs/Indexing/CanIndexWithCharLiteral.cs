using System.Linq;
using FastTests;
using Raven.Abstractions.Indexing;
using Raven.Client.Indexing;
using Raven.Client;
using Xunit;

namespace SlowTests.Bugs.Indexing
{
    public class CanIndexWithCharLiteral : RavenTestBase
    {
        [Fact]
        public void CanQueryDocumentsIndexWithCharLiteral()
        {
            using (var store = GetDocumentStore())
            {
                store.DatabaseCommands.PutIndex("test", new IndexDefinition
                {
                    Maps = { "from doc in docs select  new { SortVersion = doc.Version.PadLeft(5, '0') }" },
                    Fields = { { "SortVersion", new IndexFieldOptions { Storage = FieldStorage.Yes } } }
                });

                using (var s = store.OpenSession())
                {
                    var entity = new { Version = "1" };
                    s.Store(entity);
                    s.SaveChanges();
                }

                using (var s = store.OpenSession())
                {
                    Assert.Equal(1, s.Query<object>("test").Customize(x => x.WaitForNonStaleResults()).Count());
                    Assert.Equal("00001", s.Query<object>("test").Customize(x => x.WaitForNonStaleResults()).ProjectFromIndexFieldsInto<Result>().First().SortVersion);
                }
            }
        }

        private class Result
        {
            public string SortVersion { get; set; }
        }
    }
}
