﻿using System;
using Sparrow.Json;

namespace Raven.NewClient.Client.Exceptions
{
    public class RavenException : Exception
    {
        public RavenException()
        {
        }

        public RavenException(string message)
            : base(message)
        {
        }

        public RavenException(string message, Exception inner)
            : base(message, inner)
        {
        }

        public static RavenException Generic(string error, BlittableJsonReaderObject json)
        {
            return new RavenException($"{error}. Response: {json}");
        }
    }
}