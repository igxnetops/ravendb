using System;
using System.Linq;
using FastTests;
using Raven.Client.Indexes;
using Xunit;

namespace SlowTests.Bugs.Indexing
{
    public class CanMultiMapIndexNullableValueTypes : RavenTestBase
    {
        private class Company
        {
            public decimal? Turnover { get; set; }
        }

        private class Companies_ByTurnover : AbstractMultiMapIndexCreationTask
        {
            public Companies_ByTurnover()
            {
                AddMap<Company>(companies => from c in companies
                                             select new { c.Turnover });                              
            }
        }

        [Fact]
        public void WillNotProduceAnyErrors()
        {
            using (var store = GetDocumentStore())
            {
                var indexCreationTask = new Companies_ByTurnover();
                indexCreationTask.Execute(store);

                using (var s = store.OpenSession())
                {
                    s.Store(new Company { Turnover = null });
                    s.Store(new Company { Turnover = 1 });
                    s.Store(new Company { Turnover = 2 });
                    s.Store(new Company { Turnover = 3 });
                    s.SaveChanges();
                }

                using (var s = store.OpenSession())
                {
                    var results = s.Query<Company, Companies_ByTurnover>()
                        .Customize(x => x.WaitForNonStaleResults(TimeSpan.FromMinutes(1)))
                        .ToArray();

                    Assert.Equal(results.Length, 4);
                }

                var db = GetDocumentDatabaseInstanceFor(store).Result;
                var errorsCount = db.IndexStore.GetIndexes().Sum(index => index.GetErrors().Count);

                Assert.Equal(errorsCount, 0);
            }
        }
    }
}
