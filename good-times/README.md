# Begin

## Seed

I need to develop an app, using good foundational principles, to prevent the need for rework and codebase migrations in the future. I will work with you to build each component as standalone services. I will be using docker and docker compose to test the solution.

Our first component, is a backend API for managing metadata about datasets that exist across various public APIs, such as all the free public APIs listed here: https://github.com/public-apis/public-apis. This component will be a critical service used by other apps that need to know the available datasets, what data they contain and how to query them.

## Refine

ok, let's narrow the scope down to just this one component, which will only be accessed by other applications. There may be the need for a dataset administrator to manually configure the available datasets.

as for the schema, I have no idea. somethign useful for machines to use. the purpose of this component is to provide information about available datasets, what data they contain and how to query them.

For storage technology, we have existing robust clusters that provide Redis, Postgresql, MongoDB and Kafka. We are allowed to use any combination of these technologies that best suits our architecture.

## Refine

That Data Model looks like a good start. Let's write the engineering specs for this component for a MIxtral Instruct powered AI LLM to understand.