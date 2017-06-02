<?php

namespace PIA\appBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\Form\Extension\Core\Type\TextType;
use Symfony\Component\Form\Extension\Core\Type\SubmitType;
use PIA\appBundle\Entity\Jobs;

class JobsController extends Controller {

    public function listAction() {

        $repository = $this->getDoctrine()->getRepository('PIABundle:Jobs');

        $user_id = $this->getUser()->getId();

        $query = $repository->createQueryBuilder('p')
                ->where('p.user = :user')
                ->setParameter('user', $user_id)
                ->orderBy('p.id', 'ASC')
                ->getQuery();
        $jobs = $query->getResult();

        return $this->render('PIABundle:Jobs:job_list.html.twig', array(
                    'jobs' => $jobs
        ));
    }

    public function addAction() {

        $job = new Jobs();

        $form = $this->createFormBuilder($job)
                ->add('caption', TextType::class)
                ->add('zeroLink', TextType::class)
                ->add('Save', SubmitType::class, array('label' => 'Create Job'))
                ->getForm();

        return $this->render('PIABundle:Editor:job_edit.html.twig', array(
            'form' => $form->createView()
        ));
    }

}
