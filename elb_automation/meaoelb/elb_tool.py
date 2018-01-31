import argparse


from meaoelb.elb_ctx import ELBContext
from meaoelb.defaults import ELBConfigDefaults
from meaoelb.config import ELBAtts, ELBAttIdleTimeout


class ELBTool:
    def __init__(
            self,
            aws_region,
            target_cluster,
            asg_name,
            vpc_id,
            subnet_ids,
            dry_run_mode=True,
            parse_cli_args=True):
        """
        A convenience class for setting up the ELBConfig and ELBConfigDefaults objects.
        """
        self.ctx = ELBContext(aws_region, dry_run_mode=dry_run_mode)
        self.cfg_defaults = ELBConfigDefaults(
            self.ctx,
            target_cluster=target_cluster,
            asg_name=asg_name,
            vpc_id=vpc_id,
            subnet_ids=subnet_ids)
        self.all_elbs = []
        if parse_cli_args:
            self.parse_cli_args()

    def parse_cli_args(self):
        parser = argparse.ArgumentParser()
        parser.add_argument(
            "--apply",
            help="Apply changes",
            action="store_true")
        args = parser.parse_args()
        if args.apply:
            print("X" * 50)
            print("DRY RUN MODE HAS BEEN DISABLE")
            print("X" * 50)
            self.ctx.dry_run_mode = False
        else:
            print("Dry run mode is enabled")
            self.ctx.dry_run_mode = True

    def define_elb(self, service_namespace, service_name, ssl_arn):
        """
        A convenience method for defining an ELB and storing it in 
        a list to be created via create_elbs()
        """
        service_def = self.cfg_defaults.default_service_config(
            service_namespace=service_namespace,
            service_name=service_name,
            ssl_arn=ssl_arn)
        self.all_elbs.append(service_def)
        return service_def

    def define_elb_http(self, service_namespace, service_name, ssl_arn):
        """
        TODO
        A convenience method for defining an ELB and storing it in 
        a list to be created via create_elbs()
        """
        service_def = self.cfg_defaults.default_service_config_http(
            service_namespace=service_namespace,
            service_name=service_name,
            ssl_arn=ssl_arn)
        self.all_elbs.append(service_def)
        return service_def


    def show_elbs(self):
        for elb in self.all_elbs:
            elb.show()

    def create_and_bind_elbs(self):
        """
        Create all defined ELBs and bind them to an ASG
        """
        print("-" * 50)
        for elb in self.all_elbs:
            self.ctx.create_elb(service_config = elb, 
                                asg_name = self.cfg_defaults.asg_name)
