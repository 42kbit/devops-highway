Those are two separate modules, they have a separate tfstate,
and communitcate via outputs. (they have NO relation)

bootstrap file is used to create bucket used to store tfvars remotely.
there is no locking mechanism, to avoid complexity, for demonstration purpose.
